extends PanelContainer

var main_scene

@onready var lbl_entry := $VBoxContainer/HBoxContainer/lbl_entry
@onready var lbl_error_msg := $VBoxContainer/lbl_error_msg

func _ready():
	pass # Replace with function body.

func _on_btn_cancel_button_down():
	main_scene.show_top_menu()

func _on_btn_ok_button_down():
	var error = ""
	var profile : String = lbl_entry.text
	profile = profile.strip_edges(true, true)
	if profile.is_empty():
		error = "Profile name can't be empty"
	
	if GameState.is_profile_exists(profile):
		error = "Duplicate Profile existed. Use another name"
	
	if not error.is_empty():
		lbl_error_msg.text = error
		return
		
	#profile name checks succesful. Make a new profile
	var dir = DirAccess.open("user://profiles")
	dir.make_dir(profile)
	GameState.profile = profile
	main_scene.start_new_game()
