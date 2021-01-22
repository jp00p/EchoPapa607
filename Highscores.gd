extends Control

onready var score_list = $Margin/Scores/Scroll/Center/ScoreList

func _ready():
	$GetScores.request("https://jp00p.com/echo/get_high_score.php")

func _on_GetScores_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var rank = 1
	for person in json.result:
		var num_label = Label.new()
		var name_label = Label.new()
		var score_label = Label.new()
		
		num_label.text = "#" + str(rank)
		num_label.align = Label.ALIGN_RIGHT
		
		name_label.text = str(person.name)
		name_label.align = Label.ALIGN_CENTER
		
		score_label.text = str(person.score)
		score_label.align = Label.ALIGN_LEFT
		
		score_list.add_child(num_label)
		score_list.add_child(name_label)
		score_list.add_child(score_label)
		
		rank += 1


func _on_BackToMenu_pressed():
	get_tree().change_scene("res://Title.tscn")
