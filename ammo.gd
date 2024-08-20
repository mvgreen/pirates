extends Node2D

class_name Ammo

@export var ship: Ship

var left_timeout = 0
var right_timeout = 0
var front_timeout = 0

func _process(delta):
	left_timeout = max(0, left_timeout - delta)
	right_timeout = max(0, right_timeout - delta)
	front_timeout = max(0, front_timeout - delta)
	
	if left_timeout <= 0:
		if ship.left_cannons_time > 0:
			$Left.text = "Left Cannons: Reloading " + str(floor(ship.left_cannons_time))
		else:
			$Left.text = ""
			
	if right_timeout <= 0:
		if ship.right_cannons_time > 0:
			$Right.text = "\n\nRight Cannons: Reloading " + str(floor(ship.right_cannons_time))
		else:
			$Right.text = ""
			
	if front_timeout <= 0:
		if ship.front_cannons_time > 0:
			$Front.text = "\n\n\n\nFront Cannons: Reloading " + str(floor(ship.front_cannons_time))
		else:
			$Front.text = ""

func set_hit_count(direction: String, amount: int):
	var hits
	if amount == 1:
		hits = " hit!"
	else:
		hits = " hits!"
	if direction == "Left":
		left_timeout = 3
		$Left.text = "Left Side: " + str(amount) + hits
	elif direction == "Right":
		right_timeout = 3
		$Right.text = "\n\nRight Side: " + str(amount) + hits
	else:
		front_timeout = 3
		$Front.text = "\n\n\n\nFront Side: " + str(amount) + hits
