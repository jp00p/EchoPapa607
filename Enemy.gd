extends KinematicBody2D

signal enemy_death(pos)
signal enemy_win
signal enemies_at_the_barrier

var speed = 15

var moving = false
var moving_right = true
var moving_down = false
var max_movement = 138
var move_down_distance = 16
var distance_travelled = 0
var touching_wall = false

var my_row = 0
var my_level = 1
var my_wave = 1

var colors = {
	1: [ # level 1
		[Color("#f72585"),Color("#7209b7"),Color("#3a0ca3"),Color("#4361ee"),Color("#4cc9f0")], #wave 1
		[Color("#F73725"),Color("#B809A0"),Color("#8A0BA3"),Color("#7E42ED"),Color("#4D73F0")], #wave 2
		[Color("#F7A725"),Color("#B80943"),Color("#A30B6C"),Color("#D942ED"),Color("#7E4DF0")], #wave 3
	],
	2: [ # level 2
		[Color("#10567E"),Color("#183A37"),Color("#EFD6AC"),Color("#C44900"),Color("#432534")], #wave 1
		[Color("#101B7D"),Color("#182B3B"),Color("#E5F0AD"),Color("#C4B100"),Color("#422524")], #wave 2
		[Color("#3F107D"),Color("#18193B"),Color("#C1F0AD"),Color("#6FC400"),Color("#423524")], #wave 3
	],
	3: [ # level 3
		[Color("#009227"),Color("#FF7D00"),Color("#E9CE2C"),Color("#F9DC5C"),Color("#E5F993")], #wave 1
		[Color("#087860"),Color("#E1D600"),Color("#98D01F"),Color("#BCEE3C"),Color("#9BF270")], #wave 2
		[Color("#9D0909"),Color("#FD0000"),Color("#E32828"),Color("#F24C4C"),Color("#F47C7C")], #wave 3
	]
}

signal bring_it_down

func _ready():
	randomize()
	$ShootTimer.wait_time = rand_range(2,10)
	$ShootTimer.start()
	modulate = colors[my_level][my_wave-1][my_row]
	speed = speed * ((my_level + my_wave)/2)

func _process(delta):
	if global_position.y >= 550:
		emit_signal("enemies_at_the_barrier")
	if global_position.y >= 625:
		emit_signal("enemy_win")
		return
	var velocity = Vector2.ZERO
	if not moving:
		return
	if moving_down:
		position.y += move_down_distance
		moving_right = !moving_right
		speed += (speed * 0.025) # increase speed
		moving_down = false
	elif moving_right:
		touching_wall = false
		velocity = Vector2(1, 0) * speed
		distance_travelled += speed
	else:
		touching_wall = false
		velocity = Vector2(-1, 0) * speed
		distance_travelled += speed
	
	var collision = move_and_collide(velocity * delta)
	
	if collision and not touching_wall:
		touching_wall = true
		moving_down = true
		emit_signal("bring_it_down")
	
func _on_Hitbox_body_entered(body):
	if "Bullet" in body.name and body.enemy_bullet:
		return
	if "Bullet" in body.name:
		emit_signal("enemy_death", self.global_position)
		body.queue_free()
		queue_free()
	
func shoot():
	if not moving:
		return
	var b = load("res://Bullet.tscn").instance()
	b.enemy_bullet = true
	$LaserSound.play()
	b.SPEED = 200 + (my_level*50) + (my_wave * 10) # set bullet speed based on level/wave
	b.modulate = Color("#00ff00")
	b.set_collision_mask_bit(2, false)
	b.shoot_direction = "down"
	b.transform = $Muzzle.global_transform # set bullet's position equal to the muzzle
	get_tree().get_root().get_node("Main/Projectiles").add_child(b)

func _on_ShootTimer_timeout():
	if rand_range(0,1) <= 0.5:
		shoot()
