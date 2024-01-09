extends BPBFSM_STATE

var camera : Camera3D
var sensor : PlayerSensor
var timeout := 0.5

func entering():
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	body.fly_entering()
	
func working(_delta):
	pass
	
func exiting():
	body.walk_entering()
	body.load_default_vars()
	pass

