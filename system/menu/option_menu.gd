extends PanelContainer

var main_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func end():
	main_scene.show_top_menu()


func _on_btn_display_button_down():
	pass # Replace with function body.
	main_scene.show_menu("display_menu")


func _on_btn_control_button_down():
	pass # Replace with function body.
	main_scene.show_menu("control_menu")


func _on_btn_audio_button_down():
	main_scene.show_menu("audio_menu")


func _on_btn_exit_button_down():
	end()
