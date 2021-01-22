extends Node2D

var DEBUG = true

var screen_size = Vector2()
var invader_rows = 5
var invader_cols = 7
var invader_size = 32
var col_space = 20
var row_space = 16
var hole_chance = 0.5

var game_ready = false

var wave = 1
var level = 1

var lives = 3 setget set_lives
var score = 0 setget set_score

var time_elapsed = 0.0
var missed_shots = 0.0
var hit_shots = 0.0

var win_messages = ["Hell yeah!", "Nice.", "You did it!"]

# preload scenes
onready var invader = preload("res://Enemy.tscn")
onready var hole = preload("res://Hole.tscn")
onready var jake = preload("res://Jake.tscn")
onready var bonus = preload("res://Bonus.tscn")
onready var floating_text = preload("res://FloatingText.tscn")
onready var horgon = preload("res://Horgon.tscn")
onready var ankylosaur = preload("res://Ankylosaur.tscn")
onready var boss = preload("res://Boss.tscn")
onready var explosion = preload("res://Explosion.tscn")

func _ready():
	self.lives = 3
	screen_size = get_viewport_rect().size
	$Player.connect("player_died", self, "player_died")
	new_game()
	
	
func new_game():
	# start a new game, reset the things!
	Globals.game_score = 0
	self.time_elapsed = 0.0
	self.level = 1
	self.lives = 3
	self.score = 0
	$UI.show_message("Welcome to Minos\nthe arsenal of freedom!")
	yield(get_tree().create_timer(3.5), "timeout")
	
	start_level(1, 1) # level 1, wave 1
	
func _process(delta):
	time_elapsed += delta
	if not DEBUG:
		return
		
	# DEBUG COMMANDS
	if Input.is_action_just_pressed("ui_cancel"):
		next_level()
	if Input.is_action_just_pressed("d1"):
		self.lives += 1
	if Input.is_action_just_pressed("d2"):
		spawn_horgon()
	if Input.is_action_just_pressed("d3"):
		spawn_bonus()
	if Input.is_action_just_pressed("d4"):
		spawn_ankylosaur()
	if Input.is_action_just_pressed("d5"):
		game_over()
	if Input.is_action_just_pressed("d6"):
		clear_enemies()
		start_boss_level()
	
	
func prepare_invaders():
	# layout the invaders for the level
	for Row in range(invader_rows):
		for Column in range(invader_cols):
			var i = invader.instance()
			i.my_row = Row # set row info on invader for coloring
			i.my_level = level
			i.my_wave = wave
			i.position.x = (Column * invader_size) + (Column * col_space)
			i.position.y = (Row * invader_size) + (Row * row_space)
		
			# when an invader hits the side, all invaders move down
			i.connect("bring_it_down", self, "move_invaders_down")
			i.connect("enemy_death", self, "enemy_died")
			i.connect("enemy_win", self, "enemy_win")
			$EnemyStart.add_child(i)

func prepare_boss():
	var b = boss.instance()
	b.connect("boss_hit", self, "boss_hit")
	b.connect("boss_died", self, "boss_died")
	$EnemyStart.add_child(b)

func move_invaders_down():
	# set enemies to move down
	for e in $EnemyStart.get_children():
		e.moving_down = true

func _on_HoleTimer_timeout():
	# show a hole every so often
	if rand_range(0, 1) <= hole_chance:
		show_hole()
		
func show_hole():
	# hehehehehehe
	var offsets = [-64, 64]
	var hole_x = rand_range(16, screen_size.x-16)
	var hole_y = screen_size.y - 96
	# don't hole on the player!
	if int(hole_x) in range($Player.position.x-64, $Player.position.x+64):
		hole_x = offsets[randi()%offsets.size()] # pick a random offset
	var h = hole.instance()
	h.position.y = hole_y
	h.position.x = hole_x
	$Holes.add_child(h)

func prepare_player():
	# get the player ready for a new wave
	$Player.shots_fired = 0
	missed_shots = 0.0
	hit_shots = 0.0
	$Player.respawn_player()

func set_moving(state):
	# toggle movement of player/enemies/bonus items
	for e in $EnemyStart.get_children():
		e.moving = state
	if state == true:
		$HoleTimer.start()
		$JakeTimer.start()
		$BonusTimer.start()
		$Player.start_movement()
	else:
		$HoleTimer.stop()
		$JakeTimer.stop()
		$BonusTimer.stop()
		$Player.stop_movement()

func start_level(level_num, wave_num):
	$UI.clear_message()
	time_elapsed = 0.0
	level = level_num
	wave = wave_num
	prepare_invaders() # create rows/cols of enemies
	prepare_player() # show player
	
	# show some text, wait a sec, then play!
	$UI.show_message("Level " + str(level) + " Wave " + str(wave))
	yield(get_tree().create_timer(2.5), "timeout")
	$UI.show_message("Get it player!")
	yield(get_tree().create_timer(1), "timeout")
	$UI.clear_message()
	set_moving(true)

func start_boss_level():
	$UI.clear_message()
	time_elapsed = 0.0
	level = 5
	wave = 1
	prepare_player()
	prepare_boss()
	$UI.show_message("\"Ready to make a purchase?\"")
	yield(get_tree().create_timer(2.5), "timeout")
	$UI.show_message("Get it player!")
	yield(get_tree().create_timer(1), "timeout")
	$UI.clear_message()
	set_moving(true)

func player_died():
	set_moving(false) # stop everything
	for p in $Projectiles.get_children():
		p.queue_free()
	self.lives = lives - 1 # reduce lives
	$UI.show_message("You died!")
	yield(get_tree().create_timer(3), "timeout")
	if lives > 0:
		restart_wave()
	else:
		game_over()
	
func restart_wave():
	$Player.respawn_player()
	$UI.clear_message()
	set_moving(true)

func game_over():
	# the bad ending!
	set_moving(false)
	Globals.game_score = score
	$UI.clear_message()
	$UI.show_message("Game over!")
	yield(get_tree().create_timer(3), "timeout")
	get_tree().change_scene("res://SubmitHighscore.tscn")

func enemy_win():
	set_moving(false)
	$UI.show_message("Commander Riker has been overwhelmed!")
	yield(get_tree().create_timer(2), "timeout")
	game_over()

func clear_enemies():
	for e in $EnemyStart.get_children():
		e.queue_free()
	for s in $Bonuses.get_children():
		s.queue_free()
	for p in $Projectiles.get_children():
		p.queue_free()
	
func enemy_died(pos):
	hit_shots += 1.0
	$CRT.start_screen_shake() # FX
	var this_score = ((10 * wave) + (level*10))
	self.score += this_score # add to score
	create_floating_text(this_score, pos)
	create_explosion(pos)
	for e in $EnemyStart.get_children():
		e.speed += level*0.25 # speed up other enemies
	if $EnemyStart.get_child_count() <= 1:
		# if all enemies are dead
		next_level()

func create_explosion(pos):
	var e = explosion.instance()
	e.position = pos
	add_child(e)

func boss_hit(pos):
	hit_shots += 1.0
	$CRT.start_screen_shake()
	self.score += 50
	create_floating_text(50, pos)
	if rand_range(0,1) <= 0.1:
		create_floating_text("Ouch!", pos)
	
func boss_died(pos):
	print("BOSS DIED")
	Engine.time_scale = 0.2
	self.score += 5000
	create_floating_text(5000, pos)
	yield(get_tree().create_timer(0.5), "timeout")
	Engine.time_scale = 1
	next_level()
	
func create_floating_text(val, pos):	
	var t = floating_text.instance()
	t.new_text = val
	t.position = pos
	t.velocity = Vector2(rand_range(-50, 50), -100)
	add_child(t)
	
func next_level():
	set_moving(false)
	$UI.clear_message()
	var time_bonus = int(100 - time_elapsed) * level * 5
	var accuracy = get_accuracy()
	var acc_bonus = int(accuracy)*10
	var total_bonus = time_bonus + acc_bonus
	var yay = win_messages[randi()%win_messages.size()]
	var messages = [
		str(yay), 
		"Time bonus: " + str(time_bonus), 
		"Accuracy: " + str(int(accuracy))+"%",
		"Accuracy bonus: " + str(acc_bonus)
	]
	$UI.show_messages(messages)
	self.score += total_bonus
	clear_enemies()
	if level == 5:
		# if we killed the boss, end the game!
		go_to_ending()
		return
		
	wave = wave + 1 # increment wave
	
	if wave > 3:
		# if we just beat wave 3, reset the wave to 1 and increment level
		level += 1
		wave = 1
	
	yield(get_tree().create_timer(messages.size()+2), "timeout") # pause
	
	if level == 4:
		# if we just beat level 3 wave 3, start boss fight
		level = 5
		start_boss_level()
	else:
		# otherwise start next level/wave
		start_level(level, wave)

func go_to_ending():
	Globals.game_score = score
	get_tree().change_scene("res://SubmitHighscore.tscn")
	pass


func spawn_bonus():
	# spawn a bonus item (gives points, plays sounds, creates joy)
	var b = bonus.instance()
	b.position.y = 64
	b.position.x = 0
	b.connect("bonus_died", self, "bonus_died")
	$Bonuses.add_child(b)
	
func spawn_horgon():
	# spawn a horgon (gives a 1up)
	var h = horgon.instance()
	h.position.y = 64
	h.position.x = 0
	h.connect("horgon_died", self, "horgon_died")
	$Bonuses.add_child(h)

func spawn_ankylosaur():
	# spawn an ankylosaur (gives beard power!)
	var a = ankylosaur.instance()
	a.position.y = 64
	a.position.x = 0
	a.connect("ankylosaur_died", self, "ankylosaur_died")
	$Bonuses.add_child(a)

func bonus_died(pos, sound):
	# when a bonus items gets destroyed
	hit_shots += 1
	var scores = [150, 200, 250, 300, 350]
	var this_score = scores[randi()%scores.size()]
	self.score += this_score
	create_floating_text(this_score, pos)
	Audio.play("res://sounds/"+str(sound))

func horgon_died(pos):
	# when a horgon gets destroyed
	hit_shots += 1
	self.lives += 1
	create_floating_text("1up!", pos)
	Audio.play("res://sounds/drunkshimoda.ogg")
	
func ankylosaur_died(pos):
	# when an akylosaur dies
	hit_shots += 1
	create_floating_text("Beard!", pos)
	player_powerup_shoot()
	Audio.play("res://sounds/ankylosaur.ogg")

func _on_JakeTimer_timeout():
	# for some reason jake pops up
	if rand_range(0,1) <= 0.05:
		var j = jake.instance()
		$Jakes.add_child(j)

func _on_BonusTimer_timeout():
	# spawn one of the things that shows up across the top
	var roll = randi()%100 # (0-100)
	if roll in range(95,100):
		spawn_horgon()
	if roll in range(75, 94):
		spawn_ankylosaur()
	if roll in range(25, 74):
		spawn_bonus()
	
func player_powerup_shoot():
	# player shot the ankylosaur
	$Player.shoot_speeed_powerup()


# setters/getters

func set_lives(val):
	lives = max(val, 0)
	$UI.set_lives_number(lives)

func set_score(val):
	score = val
	$UI.set_score(score)
	
func get_accuracy():
	# get the accuracy for this wave
	var total = $Player.shots_fired
	if hit_shots == 0 or total == 0:
		return 0
	var acc = (hit_shots/total*100)
	return acc	

func missed_shot():
	# player missed a shot
	missed_shots += 1.0
