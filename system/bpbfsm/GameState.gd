extends Node

signal gamestate_changed

enum _STATE {
	MAIN_MENU,
	SYSTEM_MENU,
	GAMEPLAY_MENU,
	EVENT,
	DIALOG,
	GAMEPLAY,
}

@export var gamestate : _STATE = _STATE.GAMEPLAY:
	get:
		return gamestate
	set(value):
		gamestate = value
		emit_signal("gamestate_changed")
		

var profile := "Profile1"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("profiles"):
		dir.make_dir("profiles")
		
	PhysicsServer3D.set_active(true)
	

func is_profile_exists(_profile):
	var dir = DirAccess.open("user://profiles")
	var found = false
	if dir:
		for d in dir.get_directories():
			if d == _profile:
				found = true
	return found
			
