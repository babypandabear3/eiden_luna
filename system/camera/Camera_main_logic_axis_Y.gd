extends Node3D

@onready var axis_x = $axis_X
@onready var camera_target = $axis_X/camera_target

@export var noise : FastNoiseLite
@export var trauma := 0.0 #limit 0.0 to 1.0

@export var max_x := 150
@export var max_y := 150
@export var max_r := 25

@export var time_scale := 150

@export var decay := 0.3 #limit 0.0 to 1.0

var time := 0.0

func _ready():
	set_process(false)

func get_axis_y():
	return self
	
func get_axis_x():
	return axis_x
	
func add_trauma(trauma_in):
	trauma = clamp(trauma + trauma_in, 0, 1)
	time = 0.0
	set_process(true)
	
func _process(delta):
	time += delta
	
	var shake = pow(trauma, 2)
	camera_target.position.x = noise.get_noise_3d(time * time_scale, 0, 0) * max_x * shake
	camera_target.position.y = noise.get_noise_3d(0, time * time_scale, 0) * max_y * shake
	#rotation_degrees = noise.get_noise_3d(0, 0, time * time_scale) * max_r * shake
	
	if trauma > 0: trauma = clamp(trauma - (delta * decay), 0, 1)
	if is_equal_approx(trauma, 0.0):
		set_process(false)

# EXAMPLE on how to use trauma for screen shake
#func _input(_event):
#	if Input.is_action_just_pressed("ui_accept"):
#		add_trauma(0.10)
