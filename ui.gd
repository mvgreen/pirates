extends Node2D

var ship: Ship

@export var repair: Button
@export var steering: Button
@export var acceleration: Button
@export var accuracy: Button
@export var reload: Button
@export var notification: Button
@export var resources: Button

func on_ship_set():
	($RumNode as Node2D).visible = ship.is_island_nearby
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)
	repair.text = "Full repair: " + str(ship.carpenters_cost + 1) + " [" + str(ship.hull_hp) + "]"
	steering.text = "Upgrade helmsman - improve steering: "+ str(ship.helmsman_skill + 1)
	acceleration.text = "Upgrade seamen - improve acceleration: " + str(ship.seamen_skill + 1)
	accuracy.text = "Upgrade gunners - improve accuracy: " + str(ship.gunners_skill + 1)
	reload.text = "Upgrade powder monkeys - improve reload time: " + str(ship.powder_monkeys_skill + 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	repair.pressed.connect(on_repair)
	steering.pressed.connect(on_steering)
	acceleration.pressed.connect(on_acceleration)
	accuracy.pressed.connect(on_accuracy)
	reload.pressed.connect(on_reload)
	$RumNode/Rum.pressed.connect(on_buy)

func on_buy():
	if ship.gold < 500:
		notification.text = "Not enough gold!"
		return
	else:
		ship.gold -= 500
		ship.rum += 1
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)
	

func on_acceleration():
	var cost = ship.seamen_skill + 1
	var rum = ship.rum
	if cost > 5:
		return
	if rum < cost: 
		notification.text = "Not enough rum!"
		return
	else:
		ship.rum -= cost
	ship.seamen_skill += 1
	if cost == 5:
		acceleration.text = "Max Level"
	else:
		acceleration.text = "Upgrade seamen - improve acceleration: " + str(ship.seamen_skill + 1)
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)


func on_accuracy():
	var cost = ship.gunners_skill + 1
	var rum = ship.rum
	if cost > 5:
		return
	if rum < cost: 
		notification.text = "Not enough rum!"
		return
	else:
		ship.rum -= cost
	ship.gunners_skill += 1
	if cost == 5:
		accuracy.text = "Max Level"
	else:
		accuracy.text = "Upgrade gunners - improve accuracy: " + str(ship.gunners_skill + 1)
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)


func on_reload():
	var cost = ship.powder_monkeys_skill + 1
	var rum = ship.rum
	if cost > 5:
		return
	if rum < cost: 
		notification.text = "Not enough rum!"
		return
	else:
		ship.rum -= cost
	ship.powder_monkeys_skill += 1
	if cost == 5:
		reload.text = "Max Level"
	else:
		reload.text = "Upgrade powder monkeys - improve reload time: " + str(ship.powder_monkeys_skill + 1)
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)

func on_steering():
	var cost = ship.helmsman_skill + 1
	var rum = ship.rum
	if cost > 5:
		return
	if rum < cost: 
		notification.text = "Not enough rum!"
		return
	else:
		ship.rum -= cost
	ship.helmsman_skill += 1
	if cost == 5:
		steering.text = "Max Level"
	else:
		steering.text = "Upgrade helmsman - improve steering: "+ str(ship.helmsman_skill + 1)
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)
	

func on_repair():
	var cost = ship.carpenters_cost + 1
	var rum = ship.rum
	if cost > 5:
		return
	if rum < cost: 
		notification.text = "Not enough rum!"
		return
	else:
		ship.rum -= cost
	ship.carpenters_cost += 1
	ship.hull_hp = 100
	repair.text = "Full repair: " + str(ship.carpenters_cost + 1) + " (" + str(ship.hull_hp) + ")"
	notification.text = ""
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " + str(ship.rum)  + "\nGold: " + str(ship.gold)
	ship.update_hp()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	resources.text = "HP: " + str(ship.hull_hp) + "\nRum: " +\
	 str(ship.rum)  + "\nGold: " + str(ship.gold) +\
	"\nProvision: " + str(snapped(ship.provision, 1)) +\
	"\nCaptain's battery: " + str(snapped(ship.battery, 1)) 
	$RumNode.visible = ship.is_island_nearby
