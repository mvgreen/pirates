extends Node2D

class_name ShipRenderer

@export var ship_model: Ship

var ship_render_position: Vector2

var reset_collider = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ship_model.world_position = Vector2(750000,1600000)#Vector2(4169000, 1370000)
	ship_model.direction = Vector2.UP
	ship_render_position = Vector2(500, 500) #ship_model.world_position
	position = ship_render_position
	rotation = ship_model.direction.angle()
	
	($Area2D as Area2D).area_entered.connect(on_collision)

func explosion_front():
	($ExplosionFront as AnimatedSprite2D).frame = 0
	($ExplosionFront as AnimatedSprite2D).play()

func explosion_left():
	($ExplosionLeft1 as AnimatedSprite2D).frame = 0
	($ExplosionLeft1 as AnimatedSprite2D).play()
	($ExplosionLeft2 as AnimatedSprite2D).frame = 0
	($ExplosionLeft2 as AnimatedSprite2D).play()
	($ExplosionLeft3 as AnimatedSprite2D).frame = 0
	($ExplosionLeft3 as AnimatedSprite2D).play()


func explosion_right():
	($ExplosionRight1 as AnimatedSprite2D).frame = 0
	($ExplosionRight1 as AnimatedSprite2D).play()
	($ExplosionRight2 as AnimatedSprite2D).frame = 0
	($ExplosionRight2 as AnimatedSprite2D).play()
	($ExplosionRight3 as AnimatedSprite2D).frame = 0
	($ExplosionRight3 as AnimatedSprite2D).play()

func on_collision(area: Area2D):
	var parent = area.get_parent()
	if parent is Island:
		if is_equal_approx(ship_model.speed, 0.0):
			var away_from_island = (ship_model.world_position - parent.world_position).normalized()
			ship_model.world_position += away_from_island * 20
		else:
			ship_model.world_position -= ship_model.direction * 20
		ship_model.set_accelerastion_stage(0)
		ship_model.speed = 0
	if parent is PirateShipAi:
		var enemy = (parent as PirateShipAi)
		var enemy_hp = enemy.ship.hull_hp
		var player_hp = ship_model.hull_hp
		var damage = min(enemy_hp, player_hp)
		enemy.damage(damage)
		ship_model.damage(damage)
		var away_from_enemy = (ship_model.world_position - parent.ship.world_position).normalized()
		ship_model.world_position += away_from_enemy * 20
		ship_model.set_accelerastion_stage(0)
		ship_model.speed = 0
		
	if not (parent is Obstacle):
		return
	var effect_type = (parent as Obstacle).effect_type
	var effect_value = (parent as Obstacle).effect_value
	
	if effect_type == Obstacle.EFFECT_DAMAGE:
		ship_model.damage(effect_value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = ship_model.direction.angle()
	pass
