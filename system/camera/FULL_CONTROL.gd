extends BPBFSM_STATE

var camera_sensitivity := 50.0 #THIS SHOULD BE READ FROM GAME SETTING
var camera_gamepad_sensitivity := 50.0
var camera_multiply = 0.0001
var camera_gamepad_multiply = 0.001
var camera : Camera3D
var axis_x : SpringArm3D
var axis_y : Node3D

var camera_x_limit_high := 60.0
var camera_x_limit_low := -89.0

var position_target : Node3D
 
func _input(event):
	if not axis_y:
		return
		
	if event is InputEventMouseMotion:
		var motion = event.relative
		axis_y.rotate_y(-motion.x * camera_sensitivity * camera_multiply)
		axis_x.rotate_x(-motion.y * camera_sensitivity * camera_multiply)
		axis_x.rotation_degrees.x = clampf(axis_x.rotation_degrees.x, camera_x_limit_low, camera_x_limit_high)
		
func entering():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	axis_x = main.get_axis_x()
	axis_y = main.get_axis_y()
	
	position_target = main.get_position_target()
	
func working(_delta):
	if weakref(position_target).get_ref():
		main.global_transform = main.global_transform.interpolate_with(position_target.global_transform, 0.1)
	
	var dir_x = Input.get_axis("camera_right", "camera_left")
	var dir_y = Input.get_axis("camera_down", "camera_up")
	axis_y.rotate_y(dir_x * camera_gamepad_sensitivity * camera_gamepad_multiply)
	axis_x.rotate_x(dir_y * camera_gamepad_sensitivity * camera_gamepad_multiply)
	axis_x.rotation_degrees.x = clampf(axis_x.rotation_degrees.x, camera_x_limit_low, camera_x_limit_high)
	
func exiting():
	pass

