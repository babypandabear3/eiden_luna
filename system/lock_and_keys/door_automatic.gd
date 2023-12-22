extends World_Tool

@onready var hfsm = $HFSM
# Called when the node enters the scene tree for the first time.
func _ready():
	type = _TYPE.DOOR_AUTOMATIC
	hfsm.blackboard["model"] = $tmp_door_mesh
	hfsm.blackboard["open_door"] = false

func _sensor_entered(area):
	if area.is_in_group("player_foot_sensor"):
		hfsm.blackboard["open_door"] = true
	
func _sensor_exited(area):
	if area.is_in_group("player_foot_sensor"):
		hfsm.blackboard["open_door"] = false
