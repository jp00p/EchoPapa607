extends KinematicBody2D

signal enemy_death(pos)
signal boss_died(pos)
signal boss_hit(pos)

var min_speed = 100
var max_speed = 250
var speed = rand_range(min_speed, max_speed)
var moving = false
var max_hp = 50
var hp = max_hp
var hit_flash = false
var hit_flash_frames = 5
var hit_flash_counter = 0
var time = 0.0
var freq = 5
var amp = 320
var direction = Vector2()
var current_color = Color("#ffffff")

func _ready():
	var dirs = [-1, 1]
	direction.x = dirs[randi()%dirs.size()]
	direction.y = rand_range(-1, 1)
	position.y = 127
	position.x = 158

func _process(delta):
	if not moving:
		return
		
	var velocity = Vector2()
	time += delta
	velocity.x = speed * direction.x
	velocity.y += (sin(time * freq) * amp)
	move_and_slide(velocity)
	
	if get_slide_count() > 0:
		# bounce against the walls
		var collision = get_slide_collision(0)
		if collision != null:
			speed = rand_range(min_speed, max_speed)
			direction = direction.bounce(collision.normal)
	
	if hit_flash:
		# flash when hit
		hit_flash_counter += 1
		modulate = Color("#ff0000")
		if hit_flash_counter >= hit_flash_frames:
			hit_flash = false
			hit_flash_counter = 0
	else:
		modulate = current_color
		
func take_damage():
	hp -= 1
	hit_flash = true
	$BossHurt.play()
	emit_signal("boss_hit", global_position)
	if hp <= int(max_hp/2):
		# do that cool TMNT effect
		current_color = Color("#ff9999")
	if hp <= 0:
		emit_signal("boss_died", global_position)
		queue_free()
		
	
func shoot():
	if not moving:
		return
		
	var muzzle = $Eyez.get_child(randi()%$Eyez.get_child_count())
	var b = load("res://Bullet.tscn").instance()
	$LaserSound.play()
	b.enemy_bullet = true
	b.SPEED = 300
	b.modulate = Color(randf(), 1, randf())
	b.set_collision_mask_bit(2, false)
	b.shoot_direction = "down"
	b.transform = muzzle.global_transform # set bullet's position equal to the muzzle
	get_tree().get_root().get_node("Main/Projectiles").add_child(b) # dis is bad

func _on_ShootTimer_timeout():
	shoot()
