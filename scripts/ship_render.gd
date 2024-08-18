extends Node2D

class_name ShipRenderer

@export var ship_model: Ship

var ship_render_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	ship_model.world_position = Vector2(500, 300)
	ship_model.direction = Vector2.UP
	ship_render_position = ship_model.world_position
	position = ship_render_position
	rotation = ship_model.direction.angle()
	
	($Area2D as Area2D).area_entered.connect(on_collision)


func on_collision(area: Area2D):
	var parent = area.get_parent()
	if not (parent is Obstacle):
		return
	var effect_type = (parent as Obstacle).effect_type
	var effect_value = (parent as Obstacle).effect_value
	
	if effect_type == Obstacle.EFFECT_DAMAGE:
		ship_model.damage(effect_value)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = ship_model.direction.angle()
	pass
