extends Node

class_name ObstacleContainer

@export var ship: Ship
@export var shipRenderer: ShipRenderer
@export var land_announcer: Label
@export var sea_theme: AudioStreamPlayer2D
@export var port_theme: AudioStreamPlayer2D

var current_chunk: Vector2

var loaded_chunks = []

var obstacles_pool: Dictionary
var active_obstacles: Dictionary
var active_islands: Array

var pirates_pool: Dictionary
var active_pirates: Array
var island_pool: Dictionary

var obstacle_prefab: PackedScene
var island_prefab: PackedScene
var pirate_prefab: PackedScene

var disabled = false

func _ready():
	obstacle_prefab = preload("res://Obstacle.tscn")
	pirate_prefab = preload("res://PirateShipAi.tscn")
	island_prefab = preload("res://Island.tscn")
	
	current_chunk = Vector2(-1000, -1000)
	fill_obstacles_pool()
	update_loaded_chunks()
	

func set_obstacles_disabled(value: bool):
	disabled = value
	if disabled:
		forced_unload()
	else:
		var ship_chunk_x = floor(abs(ship.world_position.x) / 1000) * sign(ship.world_position.x)
		var ship_chunk_y = floor(abs(ship.world_position.y) / 1000) * sign(ship.world_position.y)
		var ship_chunk = Vector2(ship_chunk_x, ship_chunk_y)
		var to_nearest_island = get_vector_to_nearest_island(ship_chunk)
		var distance = to_nearest_island.length_squared()
		if distance <= 100 * 100:
			snap_ship_to_island(to_nearest_island)
		#reset current chunk to force the real current chunk to load
		current_chunk = Vector2(-1000, -1000)


func get_vector_to_nearest_island(ship_chunk: Vector2) -> Vector2:
	var min = ($Patterns as Patterns).island_locations.front() as Vector2
	for island_location in ($Patterns as Patterns).island_locations:
		var v = island_location as Vector2
		if v.distance_squared_to(ship_chunk) < min.distance_squared_to(ship_chunk):
			min = v
	return min - ship_chunk

func get_snapping_direction_to_island(direction: Vector2):
	var target_vector: Vector2
	if direction == Vector2(0,0):
		return null
	var angle = direction.angle()
	if abs(angle) <= PI / 4:
		target_vector = Vector2.LEFT
	elif abs(angle) >= PI * 3 / 4:
		target_vector = Vector2.RIGHT
	elif angle <= PI * 3 / 4 and angle > 0:
		target_vector = Vector2.UP
	else:
		target_vector = Vector2.DOWN
	return target_vector

func snap_ship_to_island(direction: Vector2):
	var target_vector = get_snapping_direction_to_island(direction)
	if target_vector == null:
		return
	announce_land(target_vector)
	target_vector *= 12 # move to chunk next to the edge of the island
	
	ship.world_position += (direction + target_vector) * 1000 # convert position to world coordinates


func announce_land(target: Vector2):
	var str
	if target == Vector2.UP:
		str = "South!"
	elif target == Vector2.DOWN:
		str = "North!"
	elif target == Vector2.LEFT:
		str = "East!"
	else:
		str = "West!"
	
	land_announcer.text = "Land to the " + str

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
	
	for i in range(100):
		var island = island_prefab.instantiate() as Island
		island.position = Vector2(-2000, -2000)
		island.active = false
		island.on_active_updated()
		$IslandsRenderList.add_child(island)
		island_pool[island] = false

func _process(delta):
	if disabled:
		forced_unload()
		update_music()
		return
	update_children_relative_position()
	update_loaded_chunks()

func update_music():
	var new_chunk_x = floor(abs(ship.world_position.x) / 1000) * sign(ship.world_position.x)
	var new_chunk_y = floor(abs(ship.world_position.y) / 1000) * sign(ship.world_position.y)
	var current_chunk = Vector2(new_chunk_x, new_chunk_y)
	var to_nearest_island = get_vector_to_nearest_island(current_chunk)
	var distance = to_nearest_island.length_squared()
	if distance > 11 * 11:
		if not sea_theme.playing:
			sea_theme.play()
			port_theme.stop()

func update_loaded_chunks():
	var new_chunk_x = floor(abs(ship.world_position.x) / 1000) * sign(ship.world_position.x)
	var new_chunk_y = floor(abs(ship.world_position.y) / 1000) * sign(ship.world_position.y)

	if new_chunk_x != current_chunk.x or new_chunk_y != current_chunk.y:
		current_chunk = Vector2(new_chunk_x, new_chunk_y)
		update_chunks()
		var v = ($Patterns as Patterns).island_locations.front()
		var to_finish = (current_chunk - v).length_squared()
		if to_finish <= 10 * 10:
			ship.is_finish_nearby = true
		else:
			ship.is_finish_nearby = false
		
		var to_nearest_island = get_vector_to_nearest_island(current_chunk)
		var distance = to_nearest_island.length_squared()
		if distance <= 11 * 11:
			if not port_theme.playing:
				sea_theme.stop()
				port_theme.play()
		else:
			if not sea_theme.playing:
				sea_theme.play()
				port_theme.stop()

		if distance <= 100 * 100:
			if distance <= 10 * 10:
				ship.is_island_nearby = true
			else:
				ship.is_island_nearby = false
			var target = get_snapping_direction_to_island(to_nearest_island)
			if target == null:
				land_announcer.text = ""
				return
			announce_land(target)
		else:
			ship.is_island_nearby = false
			land_announcer.text = ""

func update_children_relative_position():
	var children = $ObstaclesRenderList.get_children()
	for child in children:
		if child is Obstacle:
			child.position = child.initial_position - (ship.world_position - shipRenderer.ship_render_position)
	
	var islands = $IslandsRenderList.get_children()
	for island in islands:
		if island is Island:
			island.position = island.initial_position - (ship.world_position - shipRenderer.ship_render_position)

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


func unload_obstacles(chunk: Vector2):
	if not active_obstacles.has(chunk):
		print("empty chunk")
		return

	var obstacle_list = active_obstacles[chunk]
	for obstacle in obstacle_list:
		(obstacle as Obstacle).active = false
		(obstacle as Obstacle).on_state_changed()
		obstacles_pool[obstacle] = false
	active_obstacles.erase(chunk)


func unload_pirates(chunk: Vector2):
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


func unload_islands(chunk: Vector2):
	var to_unload = []
	for isl in active_islands:
		var island = isl as Island
		if (island.world_position as Vector2).distance_squared_to(ship.world_position) >= 2000 * 2000:
			to_unload.append(island)
			island.active = false
			island.on_active_updated()
			island_pool[island] = false
	
	for item in to_unload:
		active_islands.erase(item)


func forced_unload():
	for chunk in active_obstacles.keys():
		var obstacle_list = active_obstacles[chunk]
		for obstacle in obstacle_list:
			(obstacle as Obstacle).active = false
			(obstacle as Obstacle).on_state_changed()
			obstacles_pool[obstacle] = false
	
	active_obstacles.clear()
	
	var disabled_pirates = []
	for pirate in active_pirates:
		(pirate as PirateShipAi).active = false
		(pirate as PirateShipAi).on_ship_refreshed()
		disabled_pirates.append(pirate)
	
	for pirate in disabled_pirates:
		active_pirates.erase(pirate)
		pirates_pool[pirate] = false
	
	var to_unload = []
	for isl in active_islands:
		var island = isl as Island
		to_unload.append(island)
		island.active = false
		island.on_active_updated()
		island_pool[island] = false
	
	for item in to_unload:
		active_islands.erase(item)
	
	loaded_chunks.clear()

func unload_chunk(chunk: Vector2):
	unload_obstacles(chunk)
	unload_pirates(chunk)
	unload_islands(chunk)

func is_island(chunk: Vector2):
	for island in ($Patterns as Patterns).island_locations:
		var distance = chunk.distance_squared_to(island)
		if distance <= 9*9:
			print("Loaded " + str(chunk))
			return true
	return false

func load_chunk(chunk: Vector2, intensity: int):
	if is_island(chunk):
		var island = island_pool.keys().back() as Island
		island_pool.erase(island)
		active_islands.append(island)
		island.active = true
		island.world_position = chunk * 1000
		island.initial_position = island.world_position
		island.on_active_updated()
		return
	
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
			pirate.ship.world_position = position + chunk * 1000
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
