extends Node2D

func _ready():
	randomize()
	position.y = 660
	position.x = 452

func _on_Timer_timeout():
	queue_free()
