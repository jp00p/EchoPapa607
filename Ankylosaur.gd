extends Area2D

signal ankylosaur_died(pos)

var speed = rand_range(50,100)
var time = 0.0
var freq = 5
var amp = 5

func _process(delta):
	time += delta
	position.x += speed * delta
	position.y = 64 + (sin(time * freq) * amp)

func _on_EvasivePattern_timeout():
	speed = rand_range(50,100)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Ankylosaur_body_entered(body):
	if "Bullet" in body.name:
		emit_signal("ankylosaur_died", self.global_position)
		body.queue_free()
		queue_free()
