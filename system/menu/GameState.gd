extends Node

signal gamestate_changed
signal hour_changed
signal date_changed

enum _STATE {
	MAIN_MENU,
	SYSTEM_MENU,
	GAMEPLAY_MENU,
	GAMEPLAY,
	EVENT,
	DIALOG,
}

@export var gamestate : _STATE = _STATE.GAMEPLAY :
	get:
		return gamestate
	set(value):
		gamestate = value
		#emit_signal("gamestate_changed")
		

var profile := "Profile1"

var sky
var statistics = {}

var hour := -1
var day := -1

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("profiles"):
		dir.make_dir("profiles")
		
	call_deferred("get_special_nodes")
	
func get_special_nodes():
	sky = get_tree().get_first_node_in_group("SKY")

	hour = floori(sky.day_time)
	day = sky.day_of_year
	
	statistics["hour"] = hour
	statistics["date"] = day
	
	#THIS IS TO MAKE SURE PHYSIC SERVER IS ACTIVE
	PhysicsServer3D.set_active(true)

func is_profile_exists(_profile):
	var dir = DirAccess.open("user://profiles")
	var found = false
	if dir:
		for d in dir.get_directories():
			if d == _profile:
				found = true
	return found
			
func _physics_process(_delta):
	if not sky:
		return
		
	var t_hour = floori(sky.day_time)
	var tdate = sky.day_of_year
	
	if t_hour != statistics["hour"]:
		statistics["hour"] = t_hour
		hour_changed.emit()
		
	if tdate != statistics["date"]:
		statistics["date"] = tdate
		date_changed.emit()
		
