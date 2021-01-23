extends Node

var num_players = 8
var bus = "master"

var available = []  # The available players.

var queue = []  # The queue of sounds to play.

signal finished_sound


func _ready():
	# Create the pool of AudioStreamPlayer nodes.

	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus


func _on_stream_finished(stream):
	get_tree().get_root().get_node("Main").resume_bgm()
	available.append(stream)

func play(sound_path):
	get_tree().get_root().get_node("Main").pause_bgm()
	queue.append(sound_path)

func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
