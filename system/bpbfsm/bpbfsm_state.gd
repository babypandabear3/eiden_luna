class_name BPBFSM_STATE
extends Node

@export var state_init : String = ""

var blackboard = {}
var main : Node3D
var body : CharacterBody3D
var model : Node3D
var fsm : BPBFSM
var anim_player : AnimationPlayer
var nav_agent : NavigationAgent3D

var state_prev = ""
var state_current = ""
var state_next = ""
var state_process : BPBFSM_STATE
var state_reentering = false

var has_child = false

func _ready():
	state_next = state_init
	await get_tree().physics_frame
	if get_child_count() > 0:
		has_child = true
	
func do_job_as_parent(delta):
	state_prev = state_current
	if state_current != state_next:
		state_reentering = true
		state_current = state_next
		state_process = get_node_or_null(state_current) as BPBFSM_STATE
		
	if not state_process:
		if has_child:
			print("NEXT STATE NOT FOUND : ", state_next)
		return
	else:
		state_process.get_variables_from_parent()
		
	if state_reentering:
		state_process.entering()
		state_reentering = false
		DEBUG._print(state_current)
		
	state_process.working(delta)
	state_process.do_job_as_parent(delta)
	
	if state_next != state_current:
		state_process.exiting()
	
	
func get_variables_from_parent():
	main = get_parent().main
	body = get_parent().body
	model = get_parent().model
	fsm = get_parent().fsm
	anim_player = get_parent().anim_player
	nav_agent = get_parent().nav_agent
	blackboard = get_parent().blackboard
	
func set_next_state(_par):
	get_parent().state_next = _par
	
func set_next_states_from_root(_par : Array):
	var _parent = fsm
	for _next_state in _par:
		_parent.state_next = _next_state
		_parent.state_reentering = true
		_parent = _parent.get_node(_next_state)
		
func set_child_next_state(_par, _reentering=true):
	state_next = _par
	state_reentering = _reentering
	
func entering():
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass
