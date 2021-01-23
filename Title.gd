extends Control

func _ready():
	if TitleBgm.playing != true:
		TitleBgm.play("res://sounds/darkmateria_the_picard_song.ogg")
		TitleBgm.playing = true

func _on_StartGame_pressed():
	get_tree().change_scene("res://Tutorial.tscn")

func _on_ShowScores_pressed():
	get_tree().change_scene("res://Highscores.tscn")
