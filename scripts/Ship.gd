extends Node

class_name Ship

signal game_over
@export var hpBar: Label

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

var world_position = Vector2(0.0, 0.0)
var direction = Vector2.DOWN

var speed = 0.0
var acceleration_stage = 0
var max_acceleration_stage = 3

var speed_limit_partition = 0.0

var max_speed_normal = 10
var max_speed_storm = 15

var deceleration_speed = 1

func update_acceleration_stage(up: bool):
	if up:
		acceleration_stage = min(max_acceleration_stage, acceleration_stage + 1)
	else:
		acceleration_stage = max(0, acceleration_stage - 1)
	speed_limit_partition = 1.0 / 3.0 * acceleration_stage

func set_accelerastion_stage(stage: int):
	if stage > max_acceleration_stage:
		acceleration_stage = max_acceleration_stage
	elif stage < 0:
		acceleration_stage = 0
	else: 
		acceleration_stage = stage
	speed_limit_partition = 1.0 / 3.0 * acceleration_stage

func get_steering_speed(): 
	return helmsman_skill * PI / 4

func get_normal_acceleration():
	return seamen_skill * 0.2 * acceleration_stage

func get_storm_acceleration():
	return seamen_skill * 1.5

func get_gunners_hit_chance():
	return gunners_skill * 0.15

func get_reload_time():
	return 10 - powder_monkeys_skill

func get_repair_amount():
	return carpenters_skill * 10

func damage(value: int):
	hull_hp = max(0, hull_hp - value)
	hpBar.text = "HP: " + str(hull_hp)
	if hull_hp <= 0:
		emit_signal("game_over")
