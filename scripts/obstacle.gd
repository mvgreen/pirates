extends Node2D

class_name Obstacle

const EFFECT_DAMAGE = 1
const EFFECT_MONEY = 2
const EFFECT_RUM = 3
const EFFECT_MAGNET = 4 

var ob_id: int
var active: bool = false
var initial_position: Vector2
var effect_type: int
var effect_value: int

func on_state_changed():
	($AnimatedSprite2D as AnimatedSprite2D).visible = active
	($Area2D/CollisionShape2D as CollisionShape2D).set_deferred("disabled", not active)
	if effect_type == EFFECT_DAMAGE:
		($AnimatedSprite2D as AnimatedSprite2D).animation = "default"
	else: 
		($AnimatedSprite2D as AnimatedSprite2D).animation = "default"
	if active:
		($AnimatedSprite2D as AnimatedSprite2D).frame = randi() % 4
		($AnimatedSprite2D as AnimatedSprite2D).play()
