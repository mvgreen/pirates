extends Node

@export var ship: Ship

# Called when the node enters the scene tree for the first time.
func _ready():
	ship.game_over.connect(on_game_over)

func on_game_over():
	print("Game Over!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

func is_storm_at(position: Vector2) -> bool:
	return false # TODO
	
func is_still_at(position: Vector2) -> bool:
	return false # TODO
