extends PanelContainer

var main_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_btn_exit_button_down():
	main_scene.show_menu("option_menu")
