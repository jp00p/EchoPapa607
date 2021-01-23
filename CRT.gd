extends CanvasLayer

var screen_shake = false
var screen

func _ready():
	screen = $CRTOverlay.get_material()
	
func _process(delta):
	if screen_shake != false:
		var shaky = rand_range(2,10)
		screen.set_shader_param("aberration_amount", shaky)

func start_screen_shake():
	if screen_shake != true:
		screen_shake = true
		$ShakeTimer.start()

func _on_ShakeTimer_timeout():
	screen_shake = false
	screen.set_shader_param("aberration_amount", 0)	


