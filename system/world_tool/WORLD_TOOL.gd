class_name World_Tool
extends Area3D

enum _TYPE {
	JUMP_POD,
	KEY_STEP_ON,
	DOOR_AUTOMATIC,
	DOOR_KEY,
	KEYRING,
	PUNCH_TO_RAGDOLL,
}

var type : _TYPE

func _init():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(7, true)
	set_collision_mask_value(7, true)
	
	area_entered.connect(_sensor_entered)
	area_exited.connect(_sensor_exited)

# Called when the node enters the scene tree for the first time.
func _ready():
	notify_property_list_changed()
	pass # Replace with function body.

func _sensor_entered(_area):
	pass

func _sensor_exited(_area):
	pass
