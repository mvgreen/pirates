extends Node2D

@export var ship_model: Ship

# Called when the node enters the scene tree for the first time.
func _ready():
	ship_model.world_position = Vector2(600, 500)
	ship_model.direction = Vector2.UP
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = ship_model.world_position
	rotation = ship_model.direction.angle()
	pass
