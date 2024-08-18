extends Label

@export var ship: Ship

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "Stage: " + str(ship.acceleration_stage) + "; Speed: " + str(snapped(ship.speed, 1)) + "\nX: " + str(snapped(ship.world_position.x, 1)) +  "Y: " + str(snapped(ship.world_position.y, 1))
	pass
