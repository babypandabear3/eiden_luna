@tool
class_name BPBFSM
extends Node

@export var state_init : String = ""

var state_prev = ""
var state_current = ""
var state_next = ""
var state_process : BPBFSM_STATE


var blackboard = {}
var _FSM_ACTIVE = false

var state_reentering = false
# Called when the node enters the scene tree for the first time.
func _ready():
	ready_0()
	await get_tree().physics_frame
	ready_1()
	await get_tree().physics_frame
	_FSM_ACTIVE = true
	
func ready_0():
	_FSM_ACTIVE = false
	state_current = ""
	state_next = state_init
	
func ready_1(): #OVERWRITE THIS FUNCTION IF EXTENDS BPBFSM CLASS
	pass


func _physics_process(delta):
	if Engine.is_editor_hint():
		return
		
	if not _FSM_ACTIVE:
		return
		
	state_prev = state_current
	if state_current != state_next:
		state_reentering = true
		state_current = state_next
		state_process = get_node_or_null(state_current) as BPBFSM_STATE
		
	if not state_process:
		return
	else:
		state_process.get_variables_from_parent()
		
	if state_reentering:
		state_process.entering()
		state_reentering = false
		
	state_process.working(delta)
	state_process.do_job_as_parent(delta)
	
	if state_current != state_next:
		state_process.exiting()
	



