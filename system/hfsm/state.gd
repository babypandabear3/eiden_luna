class_name HFSM_STATE
extends Node

@export var default_state := ""
var state_current := ""
var state_prev := ""
var state_next := ""

var active_state : HFSM_STATE
var blackboard = {}

func _ready():
	active_state = get_node_or_null(default_state)
	state_current = default_state
	state_next = state_current
	
func do_job_as_parent(_delta):
	if not active_state:
		active_state = get_node_or_null(default_state)
		if not active_state:
			return
		else:
			active_state.blackboard = blackboard
			state_current = default_state
			state_next = state_current
	
	if state_prev != state_current:
		active_state.blackboard = blackboard
		active_state.entering()
		active_state.child_entering()
		
	active_state.working(_delta)
	active_state.do_job_as_parent(_delta)
	
	if state_current != state_next:
		active_state.exiting()
		active_state = get_node_or_null(state_next)
		if not active_state:
			print("next state not found : ", state_next)
		
	state_prev = state_current
	state_current = state_next

func set_next_state(_par):
	get_parent().state_next = _par

func entering():
	pass
	
func child_entering():
	if active_state:
		active_state.blackboard = blackboard
		active_state.entering()
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

