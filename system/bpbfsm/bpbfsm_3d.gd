@tool
class_name BPBFMS_3D
extends BPBFSM

@onready var main_menu_i = preload("res://system/bpbfsm/BASE_STATES/main_menu.tscn")
@onready var system_menu_i = preload("res://system/bpbfsm/BASE_STATES/system_menu.tscn")
@onready var gameplay_menu_i = preload("res://system/bpbfsm/BASE_STATES/gameplay_menu.tscn")
@onready var event_i = preload("res://system/bpbfsm/BASE_STATES/event.tscn")
@onready var dialog_i = preload("res://system/bpbfsm/BASE_STATES/dialog.tscn")
@onready var gameplay_i = preload("res://system/bpbfsm/BASE_STATES/gameplay.tscn")

var main_states = ["MAIN_MENU", "SYSTEM_MENU", "GAMEPLAY_MENU", "EVENT", "DIALOG", "GAMEPLAY"]

@export var setup : bool = false :
	set(value):
		setup = false
		_setup()
		
@export var main_path : NodePath
@export var body_path : NodePath
@export var model_path : NodePath

var main : Node3D
var body : CharacterBody3D
var model : Node3D
var fsm : BPBFSM
var anim_player : AnimationPlayer
var nav_agent : NavigationAgent3D

func ready_1(): #OVER WRITE THIS IF EXTENDING BPBFSM
	fsm = self
	main = get_node_or_null(main_path)
	body = get_node_or_null(body_path)
	model = get_node_or_null(model_path)
	if main:
		var tmp = find_children("*", "AnimationPlayer")
		if tmp.size() > 0:
			anim_player = tmp.front()
		tmp = find_children("*", "NavigationAgent3D")
		if tmp.size() > 0:
			nav_agent = tmp.front()

func _setup():
	var instance_i = []
	instance_i.append(main_menu_i)
	instance_i.append(system_menu_i)
	instance_i.append(gameplay_menu_i)
	instance_i.append(event_i)
	instance_i.append(dialog_i)
	instance_i.append(gameplay_i)
		
	var names = []
	for o in get_children():
		names.append(o.name)
	
	var i = 0
	for state in main_states:
		if not state in names:
			var obj = instance_i[i].instantiate()
			add_child(obj)
			obj.owner = owner
			obj.name = state
			
		i += 1


