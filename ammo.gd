extends Node2D

@export var ship: Ship

func _process(delta):
	if ship.left_cannons_time > 0:
		$Left.text = "Left Cannons: Reloading " + str(floor(ship.left_cannons_time))
	else:
		$Left.text = ""
	if ship.right_cannons_time > 0:
		$Right.text = "\nRight Cannons: Reloading " + str(floor(ship.right_cannons_time))
	else:
		$Right.text = ""
	
	if ship.front_cannons_time > 0:
		$Front.text = "\n\nFront Cannons: Reloading " + str(floor(ship.front_cannons_time))
	else:
		$Front.text = ""
	
