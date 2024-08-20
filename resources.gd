extends Node2D

@export var ship: Ship

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Gold.text = "Gold: " + str(ship.gold)
	$Rum.text = "\nRum: " + str(ship.rum)
	$Provision.text = "\n\nProvision: " + str(snapped(ship.provision, 1))
	$Charge.text = "\n\n\nCaptain's battery: " + str(snapped(ship.battery, 1))
