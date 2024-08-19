extends Node2D

class_name Island

var active: bool
var world_position: Vector2
var initial_position: Vector2

func on_active_updated():
	($Sprite2D as Sprite2D).visible = active
