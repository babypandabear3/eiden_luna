@tool
extends World_Tool

enum _KEYCARD_COLOR {
	BLUE,
	GREEN,
	RED,
	YELLOW,
}

@onready var hfsm = $HFSM
@export var keycard_color : _KEYCARD_COLOR = _KEYCARD_COLOR.BLUE
@export var unique_id : int = -1
@export var create_keycard :bool = false :
	set(value):
		if value:
			_create_keycard()
		create_keycard = false
		

func _ready():
	type = _TYPE.DOOR_AUTOMATIC
	hfsm.blackboard["open_door"] = false
	hfsm.blackboard["model"] = $tmp_door_mesh

func _sensor_entered(area):
	if area is Keyring:
		if area.has_door_key(unique_id):
			hfsm.blackboard["open_door"] = true
	
	
func _sensor_exited(area):
	if area is Keyring:
		if area.has_door_key(unique_id):
			hfsm.blackboard["open_door"] = false
	

func _create_keycard():
	var keycard : KeyCard = load("res://system/lock_and_keys/keycard.tscn").instantiate()
	keycard.keycard_color = keycard_color
	var tmp_name = keycard.name
	add_child(keycard)
	keycard.owner = owner
	keycard.name = tmp_name
	
	if unique_id == -1:
		generate_door_id()
	keycard.door_id = unique_id
	notify_property_list_changed()
	print("new keycard")

func generate_door_id():
	unique_id = hash(global_transform.origin)
	pass
