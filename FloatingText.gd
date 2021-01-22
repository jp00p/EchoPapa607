extends Node2D

var new_text
var velocity = Vector2(50, -100)
var gravity = Vector2(0,1)
var mass = 200

onready var tween = $Tween

func _ready():
	$Label.text = str(new_text)
	
	tween.interpolate_property(self, "modulate", 
		Color(modulate.r, modulate.g, modulate.b, modulate.a),
		Color(modulate.r, modulate.g, modulate.b, 0.0),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7)
	
	tween.interpolate_property(self, "scale",
	Vector2.ZERO,
	Vector2.ONE,
	1.0, Tween.TRANS_QUART, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "scale",
	Vector2.ONE,
	Vector2(0.4, 0.4),
	0.5, Tween.TRANS_QUART, Tween.EASE_OUT, 0.6)
	
	tween.interpolate_callback(self, 1.0, "destroy")
	
	tween.start()
	
func _process(delta):
	velocity += gravity * mass * delta
	position += velocity * delta

func destroy():
	queue_free()
