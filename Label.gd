extends Label

@export var ship: Ship
@export var pirateRenderList: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ship_chunk_x = floor(abs(ship.world_position.x) / 1000) * sign(ship.world_position.x)
	var ship_chunk_y = floor(abs(ship.world_position.y) / 1000) * sign(ship.world_position.y)
	var ship_chunk = Vector2(ship_chunk_x, ship_chunk_y)
	text = "Chunk: " + str(ship_chunk)
	#text = str( snapped(((ship.world_position.x-pShip.world_position.x)**2)+((ship.world_position.y-pShip.world_position.y)**2), 1) )
	#text = "Stage: " + str(ship.acceleration_stage) + "; Speed: " + str(snapped(ship.speed, 0.01))+"\n"
	#text += str("angle: "+str(snapped(ship.direction.angle(),0.01)))+"\n"
	#text = str(ship.world_position)
	#text = "Stage: " + str(ship.acceleration_stage) + "; Speed: " + str(snapped(ship.speed, 0.01))
	pass
