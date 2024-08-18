extends Label

@export var ship: Ship
@export var pShip: Ship

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#text = str( snapped(((ship.world_position.x-pShip.world_position.x)**2)+((ship.world_position.y-pShip.world_position.y)**2), 1) )
	text = "Stage: " + str(ship.acceleration_stage) + "; Speed: " + str(snapped(ship.speed, 0.01))+"\n"
	text += str("angle: "+str(snapped(ship.direction.angle(),0.01)))+"\n"
	#text = str(ship.world_position)
	#text = "Stage: " + str(ship.acceleration_stage) + "; Speed: " + str(snapped(ship.speed, 0.01))
	pass
