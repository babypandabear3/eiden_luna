@tool
class_name HFSM
extends Node

@export var setup := false : 
	get:
		return setup
	set(value):
		set_setup(value)
		
@export var default_state := ""
@export var main_path :NodePath
@export var main_is_body := false
@export var model_path :NodePath
@export var navagent_path :NodePath

var blackboard = {}

var state_current := ""
var state_prev := ""
var state_next := ""

var active_state : HFSM_STATE

func _ready():
	if Engine.is_editor_hint():
		return
		
	####
	# START - THIS BLOCK IS A WORKAROUND TO REMOVE ERROR NAVIGATION NOT READY WHEN GAME STARTED
	###
	set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	set_physics_process(true)
	####
	# END - THIS BLOCK IS A WORKAROUND TO REMOVE ERROR NAVIGATION NOT READY WHEN GAME STARTED
	###

	process_mode = Node.PROCESS_MODE_ALWAYS
	active_state = get_node_or_null(default_state)
	state_current = default_state
	state_next = state_current
	
	var main = get_node_or_null(main_path)
	if main:
		blackboard["main"] = main
	if main and main_is_body:
		blackboard["body"] = main
		
	var model = get_node_or_null(model_path)
	if model:
		blackboard["model"] = model
		
	var navagent = get_node_or_null(navagent_path)
	if navagent:
		blackboard["navagent"] = navagent
		
func set_setup(value):
	if value:
		var default_states_i = []
		default_states_i.append( load("res://system/hfsm/main_state/main_menu.tscn") )
		default_states_i.append( load("res://system/hfsm/main_state/system_menu.tscn") )
		default_states_i.append( load("res://system/hfsm/main_state/gameplay_menu.tscn") )
		default_states_i.append( load("res://system/hfsm/main_state/event.tscn") )
		default_states_i.append( load("res://system/hfsm/main_state/dialog.tscn") )
		default_states_i.append( load("res://system/hfsm/main_state/gameplay.tscn") )
		
		
		for s in default_states_i:
			var o = s.instantiate()
			add_child(o)
			o.owner = owner
	setup = false
	return setup
	
func _physics_process(_delta):
	if Engine.is_editor_hint():
		return
		
	if not active_state:
		return
		
	if state_prev != state_current:
		active_state.blackboard = blackboard
		active_state.entering()
		
	active_state.working(_delta)
	active_state.do_job_as_parent(_delta)
	
	if state_current != state_next:
		active_state.exiting()
		active_state = get_node_or_null(state_next)
		if not active_state:
			print(get_parent().name, "=next state not found : ", state_next)
		
	state_prev = state_current
	state_current = state_next

func set_next_state(_par):
	if Engine.is_editor_hint():
		return
	get_parent().state_next = _par
