extends PanelContainer

var main_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_btn_new_button_down():
	main_scene.show_menu("profile_new")
	pass # Replace with function body.


func _on_btn_load_button_down():
	pass # Replace with function body.


func _on_btn_option_button_down():
	pass # Replace with function body.
	main_scene.show_menu("option_menu")


func _on_btn_exit_button_down():
	pass # Replace with function body.
	get_tree().quit()


func _on_btn_continue_button_down():
	pass # Replace with function body.
