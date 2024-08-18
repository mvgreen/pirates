extends Node

@export var ship: Ship
@export var shipRenderer: ShipRenderer

var current_chunk: Vector2

var loaded_chunks = []

var obstacles_pool: Dictionary
var active_obstacles: Dictionary

var pirates_pool: Dictionary
var active_pirates: Array

var obstacle_prefab: PackedScene

var pirate_prefab: PackedScene

func _ready():
	obstacle_prefab = preload("res://Obstacle.tscn")
	pirate_prefab = preload("res://PirateShipAi.tscn")
	
	current_chunk = Vector2(1000, 1000)
	fill_obstacles_pool()
	update_loaded_chunks()


func fill_obstacles_pool():
	for i in range(300):
		var obstacle = obstacle_prefab.instantiate()
		$ObstaclesRenderList.add_child(obstacle)
		(obstacle as Obstacle).ob_id = i
		obstacle.on_state_changed()
		obstacles_pool[obstacle] = false
	
	for i in range(2):
		var pirate = pirate_prefab.instantiate() as PirateShipAi
		pirate.playerShip = ship
		pirate.shipRenderer = shipRenderer
		$PiratesRenderList.add_child(pirate)
		pirates_pool[pirate] = false

func _process(delta):
	update_children_relative_position()

	update_loaded_chunks()


func update_loaded_chunks():
	var new_chunk_x = floor(abs(ship.world_position.x) / 1000) * sign(ship.world_position.x)
	var new_chunk_y = floor(abs(ship.world_position.y) / 1000) * sign(ship.world_position.y)

	if new_chunk_x != current_chunk.x or new_chunk_y != current_chunk.y:
		current_chunk = Vector2(new_chunk_x, new_chunk_y)
		update_chunks()

func update_children_relative_position():
	var children = $ObstaclesRenderList.get_children()
	for child in children:
		if child is Obstacle:
			child.position = child.initial_position - (ship.world_position - shipRenderer.ship_render_position)

func update_chunks():
	var chunks_to_unload = []
	for chunk in loaded_chunks:
		var chunk_x = (chunk as Vector2).x
		var chunk_y = (chunk as Vector2).y
		if abs(chunk_x - current_chunk.x) >= 2 or abs(chunk_y - current_chunk.y) >= 2:
			var pos = Vector2(chunk_x, chunk_y)
			chunks_to_unload.append(pos)
			unload_chunk(pos)

	for chunk in chunks_to_unload:
		loaded_chunks.erase(chunk)

	var chunks_to_load = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			var vector = Vector2(x, y) + current_chunk
			if !loaded_chunks.has(vector):
				load_chunk(vector, 6)
				chunks_to_load.append(vector)

	loaded_chunks.append_array(chunks_to_load)


func unload_chunk(chunk: Vector2):
	if not active_obstacles.has(chunk):
		print("empty chunk")
		return

	var obstacle_list = active_obstacles[chunk]
	for obstacle in obstacle_list:
		(obstacle as Obstacle).active = false
		(obstacle as Obstacle).on_state_changed()
		obstacles_pool[obstacle] = false
	active_obstacles.erase(chunk)
	
	var disabled_pirates = []
	for pirate in active_pirates:
		if ((pirate as PirateShipAi).ship.world_position - ship.world_position).length() < 2000:
			continue
		(pirate as PirateShipAi).active = false
		(pirate as PirateShipAi).on_ship_refreshed()
		disabled_pirates.append(pirate)
	
	for pirate in disabled_pirates:
		active_pirates.erase(pirate)
		pirates_pool[pirate] = false

func load_chunk(chunk: Vector2, intensity: int):
	var pattern_id = randi() % 100
	var pattern = ($Patterns as Patterns).pattern_list[pattern_id]
	var list = []
	var count = min(intensity, pattern.size())
	for i in count:
		var position = pattern[i]
		if randf() >= 0.99:
			if pirates_pool.size() == 0:
				continue
			var pirate = pirates_pool.keys().back() as PirateShipAi
			pirate.active = true
			pirate.ship.world_position = position + chunk * 1000 - shipRenderer.ship_render_position
			pirate.on_ship_refreshed()
			active_pirates.append(pirate)
			pirates_pool.erase(pirate)
			continue
			
		
		if obstacles_pool.size() == 0:
			break
		var obstacle = obstacles_pool.keys().back() as Obstacle
		obstacles_pool.erase(obstacle)
		obstacle.active = true
		obstacle.initial_position = position + chunk * 1000 - shipRenderer.ship_render_position
		obstacle.position = obstacle.initial_position - (ship.world_position - shipRenderer.ship_render_position)
		obstacle.effect_type = Obstacle.EFFECT_DAMAGE
		obstacle.effect_value = randi() % 20
		(obstacle as Obstacle).on_state_changed()
		list.append(obstacle)
	active_obstacles[chunk] = list
