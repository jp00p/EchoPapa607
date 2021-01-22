extends Area2D

signal horgon_died(pos)

var speed = rand_range(45,65)
var time = 0.0
var freq = 5
var amp = 5

func _process(delta):
	time += delta
	position.x += speed * delta
	position.y = 64 + (sin(time * freq) * amp)

func _on_EvasivePattern_timeout():
	speed = rand_range(45,65)

func _on_Horgon_body_entered(body):
	if "Bullet" in body.name:
		emit_signal("horgon_died", self.global_position)
		body.queue_free()
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
