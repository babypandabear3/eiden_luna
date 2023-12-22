extends HFSM_STATE

var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var timeout := 0.5

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	blackboard["wall_hanging_exit_to"] = ""
	body.fly_entering()
	
func working(_delta):
	if not blackboard["wall_hanging_exit_to"] == "":
		set_next_state(blackboard["wall_hanging_exit_to"])
			
	
func exiting():
	body.walk_entering()
	body.load_default_vars()
	pass
