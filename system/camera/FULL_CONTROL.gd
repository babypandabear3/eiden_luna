extends HFSM_STATE


var camera_sensitivity := 50.0 #THIS SHOULD BE READ FROM GAME SETTING

var camera_multiply = 0.0001
var camera : Camera3D
var axis_x : SpringArm3D
var axis_y : Node3D

var camera_x_limit_high := 60.0
var camera_x_limit_low := -89.0
 
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
	axis_x = blackboard.main.get_axis_x()
	axis_y = blackboard.main.get_axis_y()
	
func working(_delta):
	pass
	
func exiting():
	pass

