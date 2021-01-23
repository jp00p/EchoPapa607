extends CanvasLayer

onready var rikerface = preload("res://sprites/rikersmile.png")

func _ready():
	clear_message()

func show_message(msg):
	# show a message
	$CenterContainer/VB/AlertMessage.text = str(msg)
	
func show_messages(msgs):
	# show messages in sequence
	for m in msgs:
		$CenterContainer/VB/AlertMessage.text += str(m) + "\n"
		yield(get_tree().create_timer(1), "timeout")

func clear_message():
	# clear the message box
	$CenterContainer/VB/AlertMessage.text = ""

func set_lives_number(val):
	# set the riker faces (max 3 displayed)
	$BottomUI/PanelContainer/LivesAndScore/Lives/LivesValue.text = str(val)
	for c in $BottomUI/PanelContainer/LivesAndScore/Lives/RikerFaces.get_children():
		c.queue_free()
	if val > 3:
		val = 3
	for f in range(val):
		var face = TextureRect.new()
		face.texture = rikerface
		face.expand = true
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		face.rect_min_size = Vector2(32,32)
		$BottomUI/PanelContainer/LivesAndScore/Lives/RikerFaces.add_child(face)
	
func set_score(val):
	$BottomUI/PanelContainer/LivesAndScore/Score/ScoreValue.text = str(val).pad_zeros(6)
