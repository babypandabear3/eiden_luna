class_name KeyCard
extends World_Tool


@onready var hfsm = $BPBFMS_MAIN
@export var door_id : int = -1
@export var keycard_color : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	type = _TYPE.DOOR_AUTOMATIC
	hfsm.blackboard["model"] = $model_root
	hfsm.blackboard["colshape"] = $CollisionShape3D
	hfsm.blackboard["taken_by_player"] = false
	

func _sensor_entered(area):
	DEBUG._print("entered " + area.name)
	#if area.is_in_group("player_foot_sensor"):
	
	
func _sensor_exited(area):
	#if area.is_in_group("player_foot_sensor"):
	DEBUG._print("exited "+ area.name)

func taken():
	hfsm.blackboard["taken_by_player"] = true

func get_door_id():
	return door_id
