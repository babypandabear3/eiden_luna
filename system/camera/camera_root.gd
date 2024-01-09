extends Node3D

@export var position_target_path : NodePath
var position_target : Node3D
var look_target : Marker3D

@onready var axis_y = $axis_Y
@onready var axis_x = $axis_Y/axis_X

@onready var camera_target = $axis_Y/axis_X/camera_target


# Called when the node enters the scene tree for the first time.
func _ready():
	if not position_target:
		position_target = get_node_or_null(position_target_path)

func set_position_target(new_target):
	position_target = new_target
	
func get_position_target():
	return position_target
	
func get_axis_y():
	return axis_y
	
func get_axis_x():
	return axis_x

func set_look_target(new_target):
	look_target = new_target
	
