extends Node2D

@export var playerShip: Ship
@export var ship: Ship
@export var shipRenderer: ShipRenderer

var angle90 = PI/2
var angle22 = PI/8
var pirateShipInputs = PirateShipInputs.new()
var min_distance_between = 90000 # 300
var max_distance_between = 16000 # 400
var drift_time_passed = 0.0
var drift_vector = Vector2(randf() - 0.5, randf() - 0.5).normalized() * 0.1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ship.world_position = Vector2(100, 200)
	position = ship.world_position - playerShip.world_position


var time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var distance_between = ((playerShip.world_position.x-ship.world_position.x)**2)+((playerShip.world_position.y-ship.world_position.y)**2)
	position = ship.world_position - (playerShip.world_position - shipRenderer.ship_render_position)
	rotation = ship.direction.angle()
	#var playerPosition = playerShip.world_position
	#var playerRotation = playerShip.direction.angle()
	
	#time += delta
	#if time >= 1:
	
	if not is_too_close():
		chase()
	elif in_effective_range():
		increase_distance()
	else:
		circling()
	#	time = 0

func normalizeAngle(angle: float) -> float:
	if angle < 0:
		return angle + 2*PI
	else:
		return angle

func increase_distance():
	var direction_difference = (ship.direction - playerShip.direction)
	if abs(direction_difference.x) < 0.03  && abs(direction_difference.y) < 0.03:
		pirateShipInputs.right_pressed = false
		pirateShipInputs.left_pressed = false
		return
	
	var direction_to_playerShip = (playerShip.world_position - ship.world_position).normalized()
	var direction_to_player_normalized = normalizeAngle(direction_to_playerShip.angle())
	var current_direction_normalized = normalizeAngle(ship.direction.angle())
	
	var angle = direction_to_player_normalized - current_direction_normalized
	var target_rotation
	
	if abs(angle) < PI:
		target_rotation = angle
	else:
		target_rotation = angle - 2 * PI
		
	if target_rotation > 0:
		if target_rotation < angle90:
			pirateShipInputs.right_pressed = false
			pirateShipInputs.left_pressed = true
		else:
			pirateShipInputs.right_pressed = true
			pirateShipInputs.left_pressed = false
	else:
		if abs(target_rotation) > angle90:
			pirateShipInputs.right_pressed = true
			pirateShipInputs.left_pressed = false
		else:
			pirateShipInputs.right_pressed = false
			pirateShipInputs.left_pressed = true
	pass

func circling():
	var direction_difference = (ship.direction - playerShip.direction)
	if abs(direction_difference.x) < 0.03  && abs(direction_difference.y) < 0.03:
		pirateShipInputs.right_pressed = false
		pirateShipInputs.left_pressed = false
		return
	
	var direction_to_playerShip = (playerShip.world_position - ship.world_position).normalized()
	var direction_to_player_normalized = normalizeAngle(direction_to_playerShip.angle())
	var current_direction_normalized = normalizeAngle(ship.direction.angle())
	
	var angle = direction_to_player_normalized - current_direction_normalized
	var target_rotation
	
	if abs(angle) < PI:
		target_rotation = angle
	else:
		target_rotation = angle - 2 * PI
		
	if target_rotation > 0:
		if target_rotation > angle90:
			pirateShipInputs.right_pressed = false
			pirateShipInputs.left_pressed = true
		else:
			pirateShipInputs.right_pressed = true
			pirateShipInputs.left_pressed = false
	else:
		if abs(target_rotation) < angle90:
			pirateShipInputs.right_pressed = true
			pirateShipInputs.left_pressed = false
		else:
			pirateShipInputs.right_pressed = false
			pirateShipInputs.left_pressed = true
	pass


func chase():
	var target_offset = Vector2(0, 0)#playerShip.direction.normalized() * 200
	var direction_to_playerShip = (playerShip.world_position + target_offset - ship.world_position).normalized()
	var rotation_angle = fmod(ship.direction.angle() - direction_to_playerShip.angle() + PI, 2*PI) - PI
	if rotation_angle > 0.0:
		pirateShipInputs.right_pressed = false
		pirateShipInputs.left_pressed = true
	elif rotation_angle < 0.0:
		pirateShipInputs.left_pressed = false
		pirateShipInputs.right_pressed = true
	else:
		pirateShipInputs.left_pressed = false
		pirateShipInputs.right_pressed = false
		
	if abs(ship.direction.angle()-playerShip.direction.angle()) > angle90:
		ship.set_accelerastion_stage(1)
	else:
		ship.set_accelerastion_stage(1)

func in_effective_range():
	var quad_distance = ((playerShip.world_position.x-ship.world_position.x)**2)+((playerShip.world_position.y-ship.world_position.y)**2)
	return quad_distance <= max_distance_between

func is_too_close():
	var quad_distance = ((playerShip.world_position.x-ship.world_position.x)**2)+((playerShip.world_position.y-ship.world_position.y)**2)
	return quad_distance <= min_distance_between

func _physics_process(delta: float) -> void:
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
	if pirateShipInputs.left_pressed:
		rotation = -ship.get_steering_speed() * deltaTime
	elif pirateShipInputs.right_pressed:
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

func is_storm_at(position: Vector2) -> bool:
	return false # TODO
	
func is_still_at(position: Vector2) -> bool:
	return false # TODO
