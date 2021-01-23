extends Control

func _ready():
	$Margin/SubmitScores/ScoreValue.text = str(Globals.game_score)

func _on_SendScore_request_completed(result, response_code, headers, body):
	get_tree().change_scene("res://Highscores.tscn")

func _on_SubmitButton_pressed():
	if $Margin/SubmitScores/Form/Name/NameInput.text == "":
		$Margin/SubmitScores/Form/ErrorText.text = "Please enter a nickname"
		return
	
	$Margin/SubmitScores/Form/ErrorText.text
	$Margin/SubmitScores/Form/SubmitButton.set_disabled(true)
	$Margin/SubmitScores/Form/Name/NameInput.editable = false
	var nickname = $Margin/SubmitScores/Form/Name/NameInput.text
	var score = Globals.game_score
	$SendScore.request("https://jp00p.com/echo/set_high_score.php?password=supersecretpassword&name="+str(nickname)+"&score="+str(score))


func _on_MenuButton_pressed():
	get_tree().change_scene("res://Title.tscn")
