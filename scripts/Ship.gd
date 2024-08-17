extends Node

var helmsman_skill = 2
var seamen_skill = 2
var gunners_skill = 2
var powder_monkeys_skill = 2
var carpenters_skill = 2
var carpenters_cost = 2

var hull_hp = 100
var side_cannons = 10
var front_cannons = 4
var back_cannons = 4

func get_steering_speed(): 
	return helmsman_skill * PI / 4

func get_acceleration():
	return seamen_skill

func get_gunners_hit_chance():
	return gunners_skill * 0.15

func get_reload_time():
	return 10 - powder_monkeys_skill

func get_repair_amount():
	return carpenters_skill * 10
