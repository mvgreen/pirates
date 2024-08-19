extends Node

class_name ShipControl

@export var ship: Ship
@export var pirateRenderList: Node2D

var min_distance_between = 160000
var angle45 = PI/4
var angle135 = PI*3/4

var drift_time_passed = 0.0
var drift_vector = Vector2(randf() - 0.5, randf() - 0.5).normalized() * 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	ship.game_over.connect(on_game_over)

func on_game_over():
	print("Game Over!")

func update_reload_time(delta):
	if ship.right_cannons_time > 0:
		ship.right_cannons_time -= delta
	if ship.left_cannons_time > 0:
		ship.left_cannons_time -= delta
	if ship.front_cannons_time > 0:
		ship.front_cannons_time -= delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_reload_time(delta)
	
func check_pirateShip_around():
	var pirates = pirateRenderList.get_children()
	for p in pirates:
		var pirateShip = p as PirateShipAi
		if not pirateShip.active:
			continue
		if pirateShip.ship.world_position.distance_squared_to(ship.world_position) <= min_distance_between:
			var angle_between = ship.direction.angle_to(pirateShip.ship.world_position - ship.world_position)
			if angle_between >= angle45 and angle_between <= angle135 and ship.right_cannons_time <= 0:
				print("right side")
				for i in range(ship.side_cannons):
					pass
				ship.right_cannons_time = ship.get_reload_time()
				
			elif angle_between <= -angle45 and angle_between >= -angle135 and ship.left_cannons_time <= 0:
				print("left side")
				ship.left_cannons_time = ship.get_reload_time()
			elif angle_between >= -angle45 and angle_between <= angle45 and ship.front_cannons_time <= 0:
				print("front")
				ship.front_cannons_time = ship.get_reload_time()
			else:
				pass

func _physics_process(delta):
	var position = ship.world_position
	var is_storm = is_storm_at(position)
	var is_still = is_still_at(position)
	
	var max_speed
	if is_storm: 
		max_speed = ship.max_speed_storm
	else:
		max_speed = ship.max_speed_normal
	
	var acceleration = update_acceleration(position, is_storm, is_still, max_speed * ship.speed_limit_partition, ship.speed)
	var speed = max(0, min(ship.speed + acceleration * delta, max_speed))
	var direction = update_direction(ship.direction, speed, delta)
	
	if is_equal_approx(ship.speed, 0.0):
		drift_time_passed += delta
		if drift_time_passed >= 1:
			drift_vector = Vector2(randf() - 0.5, randf() - 0.5).normalized() * 0.1
			drift_time_passed = 0.0
		position = position + drift_vector
	position = position + direction * speed
	
	ship.world_position = position
	ship.speed = speed
	ship.direction = direction


func update_direction(direction: Vector2, speed: float, deltaTime: float) -> Vector2:
	var rotation = 0.0
	if Input.is_action_pressed("direction_left"):
		rotation = -ship.get_steering_speed() * deltaTime
	elif Input.is_action_pressed("direction_right"):
		rotation = ship.get_steering_speed() * deltaTime
	
	if is_equal_approx(speed, 0.0):
		rotation = rotation * 0.5
	elif speed <= 0.5:
		rotation = rotation * 0.75
	return direction.rotated(rotation)

func update_acceleration(position: Vector2, is_storm: bool, is_still: bool, speed_limit: float, current_speed: float) -> float:
	var acceleration_active = (ship.acceleration_stage > 0) and (is_equal_approx(current_speed, 0.0) or speed_limit > current_speed)
	if not acceleration_active:
		return -ship.deceleration_speed
		
	if is_storm:
		return ship.get_storm_acceleration()
	elif not is_still:
		return ship.get_normal_acceleration()
	else:
		return -ship.deceleration_speed


func _unhandled_key_input(event):
	if event.is_action_released("direction_up"):
		ship.update_acceleration_stage(true)
	elif event.is_action_released("direction_down"):
		ship.update_acceleration_stage(false)
	elif event.is_action_released("fire"):
		check_pirateShip_around()

func is_storm_at(position: Vector2) -> bool:
	return false # TODO
	
func is_still_at(position: Vector2) -> bool:
	return false # TODO
