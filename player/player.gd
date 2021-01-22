extends KinematicBody2D

# move left and right
# shoot
# die
# start/restart

signal player_died

const SPEED = 500

var moving = false # set this to true to disable all player input

var start_position = Vector2.ZERO
var is_alive = true
var screen_size
var velocity = Vector2.ZERO # (x = 0, y = 0)
var bullet
var friction = 0.1
var acceleration = 0.05
var can_shoot = true # used for shooting cooldowns only
var shots_fired = 0
var missed_shots = 0
var hit_shots = 0
var base_shoot_speed = 0.3
var shoot_speed = base_shoot_speed

onready var normal_riker = preload("res://sprites/riker.png")
onready var powered_up_riker = preload("res://sprites/riker_powerup.png")

func _ready():
	screen_size = get_viewport_rect().size
	start_position.y = screen_size.y - 128
	start_position.x = screen_size.x/2
	position = start_position
	bullet = preload("res://Bullet.tscn")
	$ShootTimer.wait_time = shoot_speed
	
func _process(delta):
	if not moving:
		return
		
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	var direction = get_input()
	
	if direction.length() > 0:
		velocity = lerp(velocity, direction.normalized() * SPEED, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)
	
func get_input():
	var input = Vector2()
	if Input.is_action_pressed("move_right"):
		input.x += 1 # moving right
	if Input.is_action_pressed("move_left"):
		input.x -= 1 # moving left	
	return input

func shoot():
	if !can_shoot:
		return
	shots_fired += 1
	var b = bullet.instance() # create a bullet
	owner.get_node("Projectiles").add_child(b) # add bullet to the level
	b.connect("missed_shot", owner, "missed_shot")
	b.transform = $Muzzle.global_transform # set bullet's position equal to the muzzle
	b.modulate = Color("#ff0000")
	can_shoot = false
	$ShootTimer.start()

func fall_in_hole():
	stop_movement()
	$AnimationPlayer.play("hole")
	yield(get_tree().create_timer(3), "timeout")
	$AnimationPlayer.play_backwards("hole")
	yield(get_tree().create_timer(1.25), "timeout")
	$CollisionShape2D.set_deferred("disabled", false)
	moving = true
	
func stop_movement():
	$CollisionShape2D.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	moving = false
	
func start_movement():
	$CollisionShape2D.set_deferred("disabled", false)
	moving = true
	
func player_death():
	emit_signal("player_died")
	set_visible(false)
	stop_movement()

func respawn_player():
	position = start_position
	set_visible(true)

func shoot_speeed_powerup():
	$Sprite.texture = powered_up_riker
	$BuffTimer.start()
	$ShootTimer.set_deferred("wait_time", 0.1)

func _on_ShootTimer_timeout():
	can_shoot = true

func _on_BuffTimer_timeout():
	$Sprite.texture = normal_riker
	$ShootTimer.set_deferred("wait_time", base_shoot_speed)
