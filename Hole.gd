extends Area2D


func _on_Lifespan_timeout():
	queue_free()


func _on_Hole_body_entered(body):
	if body.name == "Player":
		$Lifespan.stop()
		body.position.x = position.x
		body.fall_in_hole()
		yield(get_tree().create_timer(3.5), "timeout")
		queue_free()
