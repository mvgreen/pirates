extends Node

@export var ship: Ship
@export var shipRenderer: ShipRenderer

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Obstacle:
			child.position = Vector2(-100, -100) + ship.world_position
			child.initial_position = child.position
			child.effect_type = Obstacle.EFFECT_DAMAGE
			child.effect_value = 10
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var children = get_children()
	for child in children:
		if child is Obstacle:
			child.position = child.initial_position - (ship.world_position - shipRenderer.ship_render_position)
