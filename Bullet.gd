extends KinematicBody2D

signal missed_shot

var SPEED = 400

var shoot_direction = "up" 
var collided = false
var velocity = Vector2(0, -1 * SPEED)
var enemy_bullet = false

var cell
var tile_id
var fix_tile_collision = Vector2(0, 0)

onready var enemy_graphic = preload("res://sprites/enemy_laser.png")

func _ready():
	if shoot_direction != "up":
		velocity = Vector2(0, 1 * SPEED)
		rotation_degrees = 180
		modulate = Color(0, 255, 0, 1)
		fix_tile_collision = Vector2(0, 0)
		set_collision_mask_bit(2, false)
		$Sprite.texture = enemy_graphic
		if rand_range(0,1) <= 0.5:
			$Sprite.flip_h = true

func _process(delta):
	velocity = move_and_slide(velocity, Vector2.UP)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		match collision.collider.name:
			"Barrier":
				var cell = collision.collider.world_to_map(collision.position - collision.normal - fix_tile_collision)
				var tile_id = collision.collider.get_cellv(cell)
				collision.collider.set_cellv(cell, -1)
				if shoot_direction == "up":
					emit_signal("missed_shot")
				queue_free()
			"Player":
				collision.collider.player_death()
				queue_free()
			"BulletCatcher":
				emit_signal("missed_shot")
				queue_free()
			"Boss":
				if shoot_direction == "up":
					collision.collider.take_damage()
					queue_free()
			_:
				queue_free()
		
		

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
	


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		queue_free()


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	pass
