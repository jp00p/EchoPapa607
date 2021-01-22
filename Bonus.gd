extends Area2D

signal bonus_died(pos, sound)

var speed = rand_range(15,25)
var time = 0.0
var freq = 5
var amp = 5

var this_bonus

onready var bonuses = [
	{"graphic": preload("res://sprites/bonuses/wesley.png"), "sound": "wesley.ogg"},
	{"graphic": preload("res://sprites/bonuses/worf.png"), "sound": "worf.ogg"},
	{"graphic": preload("res://sprites/bonuses/ro.png"), "sound": "ro.ogg"},
	{"graphic": preload("res://sprites/bonuses/odo.png"), "sound": "odo.ogg"},
	{"graphic": preload("res://sprites/bonuses/obrien.png"), "sound": "obrien.ogg"},
	{"graphic": preload("res://sprites/bonuses/morn.png"), "sound": "morn.ogg"},
	{"graphic": preload("res://sprites/bonuses/geordi.png"), "sound": "geordi.ogg"}
]

func _ready():
	this_bonus = bonuses[randi()%bonuses.size()]
	$Sprite.texture = this_bonus["graphic"]

func _process(delta):
	time += delta
	position.x += speed * delta
	position.y = 64 + (sin(time * freq) * amp)

func _on_EvasivePattern_timeout():
	speed = rand_range(15,45)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bonus_body_entered(body):
	if "Bullet" in body.name:
		emit_signal("bonus_died", self.global_position, this_bonus["sound"])
		body.queue_free()
		queue_free()
