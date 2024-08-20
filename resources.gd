extends Node2D

@export var ship: Ship

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Gold.text = "Gold: " + str(ship.gold)
	$Rum.text = "\nRum: " + str(ship.rum)
