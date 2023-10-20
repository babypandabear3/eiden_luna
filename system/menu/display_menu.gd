extends PanelContainer

var main_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_btn_exit_button_down():
	main_scene.show_menu("option_menu")


func _on_chk_fullscreen_toggled(button_pressed):
	var window_mode: DisplayServer.WindowMode
	match button_pressed:
		true:
			window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		false:
			window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	
	DisplayServer.window_set_mode(window_mode)
