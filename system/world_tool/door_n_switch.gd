@tool
extends Node3D

@export var step_open : bool = false :
	set(value):
		_step_open(value)
		step_open = false
	get:
		return step_open
		
@export var step_close : bool = false :
	set(value):
		_step_close(value)
		step_close = false
	get:
		return step_close

@onready var hfsm : HFSM = $HFSM
# Called when the node enters the scene tree for the first time.
func _ready():
	hfsm.blackboard["door_state_to"] = ""
	pass

func _step_open(_value):
	var switch = load("res://system/world_tool/door_step_open_switch.tscn")
	var obj = switch.instantiate()
	var tmp_name = obj.name
	add_child(obj)
	obj.owner = owner
	obj.name = tmp_name
	
func _step_close(_value):
	var switch = load("res://system/world_tool/door_step_close_switch.tscn")
	var obj = switch.instantiate()
	var tmp_name = obj.name
	add_child(obj)
	obj.owner = owner
	obj.name = tmp_name

func do_step_open():
	hfsm.blackboard["door_state_to"] = "OPENING"
	pass
	
func do_step_close():
	hfsm.blackboard["door_state_to"] = "CLOSING"
	
