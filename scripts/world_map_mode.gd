extends Node2D

@export var ship: Ship
@export var obstacles: ObstacleContainer
@export var shipControl: ShipControl

var active = false

var offset = Vector2(50,50)

var last_trail_dot: Vector2

var dot_prefab: PackedScene

func _ready():
	dot_prefab = preload("res://TrailDot.tscn")
	($ShipIcon as Node2D).position = ship.world_position / 5000 + offset
	add_trail_dot($ShipIcon.position)
	set_active(false)

func _process(delta):
	($ShipIcon as Node2D).position = ship.world_position / 5000 + offset
	($ShipIcon as Node2D).rotation = ship.direction.angle()
	if last_trail_dot.distance_squared_to($ShipIcon.position) >= 30 * 30:
		add_trail_dot($ShipIcon.position)

func set_active(value: bool):
	active = value
	if active:
		visible = true
	else:
		visible = false

func add_trail_dot(pos: Vector2):
	var dot = dot_prefab.instantiate() as Node2D
	dot.position = pos
	$TrailDots.add_child(dot)
	last_trail_dot = pos


func _unhandled_key_input(event):
	if event.is_action_released("force_unload"):
		obstacles.set_obstacles_disabled(!obstacles.disabled)
		set_active(obstacles.disabled)
		shipControl.is_world_mode = active
