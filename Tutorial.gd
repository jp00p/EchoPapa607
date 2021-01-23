extends Control

func _on_StartButton_pressed():
	TitleBgm.stop()
	get_tree().change_scene("res://main.tscn")
