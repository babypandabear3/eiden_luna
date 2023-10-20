@tool
extends Node3D

@onready var axis_y = $axis_y
@onready var axis_x = $axis_y/axis_x

var camera_sensitivity := 50.0 #THIS SHOULD BE READ FROM GAME SETTING
var camera_multiply = 0.0001
var camera_x_limit_high := 60.0
var camera_x_limit_low := -89.0

func _ready():
	pass # Replace with function body.

func _input(event):
	if not get_parent().editor_walker_active:
		return
		
	if event is InputEventMouseMotion:
		var motion = event.relative
		axis_y.rotate_y(-motion.x * camera_sensitivity * camera_multiply)
		axis_x.rotate_x(-motion.y * camera_sensitivity * camera_multiply)
		axis_x.rotation_degrees.x = clampf(axis_x.rotation_degrees.x, camera_x_limit_low, camera_x_limit_high)
		
	print("blablabla")
		
	
