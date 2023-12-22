extends HFSM_STATE

var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var timeout := 1.0

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	timeout = 1.0
	model.play_anim("ROLL")
	body.direction = model.global_transform.basis.z
	body.acc = 100.0
	body.SPEED = 20.0
	
func working(_delta):
	timeout -= _delta
	if timeout <= 0.0:
		if body.is_on_floor():
			set_next_state("GROUNDED")
		else:
			set_next_state("AIRBORNE")
	body.SPEED *= 56 * _delta
	
func exiting():
	body.load_default_vars()
	pass

