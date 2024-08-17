extends Node

var ship: Ship

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	
	var acceleration = update_acceleration(position, is_storm, is_still)
	var speed = min(ship.speed + acceleration * delta, max_speed)
	var direction = update_direction(ship.direction, delta)
	
	position = position + direction * speed
	
	ship.world_position = position
	ship.speed = speed
	ship.direction = direction


func update_direction(direction: Vector2, deltaTime: float) -> Vector2:
	var rotation = 0.0
	if Input.is_action_pressed("direction_left"):
		rotation = ship.angle_speed * deltaTime
	elif Input.is_action_pressed("direction_right"):
		rotation = -ship.angle_speed * deltaTime
	
	return direction.rotated(rotation)

func update_acceleration(position: Vector2, is_storm: bool, is_still: bool) -> float:
	var acceleration_active = Input.is_action_pressed("direction_up")
	
	if not acceleration_active:
		return -ship.deceleration_speed
		
	if is_storm:
		return ship.get_storm_acceleration()
	elif not is_still:
		return ship.get_normal_acceleration()
	else:
		return -ship.deceleration_speed


func is_storm_at(position: Vector2) -> bool:
	return false # TODO
	
func is_still_at(position: Vector2) -> bool:
	return false # TODO
