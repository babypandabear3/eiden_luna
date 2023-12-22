extends HFSM_STATE


var body : Body
var model : Model_Generic
var camera : Camera3D
var timer := 0.3
var sensor : PlayerSensor
var wall_normal :Vector3


func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	model.play_anim("HANGING-ENTER")
	body.gravity_scale = 0.0
	timer = 0.3
	
func working(_delta):
	timer -= _delta
	if Input.is_action_just_pressed("jump"):
		set_next_state("WALLJUMP")
		
	if timer <= 0:
		set_next_state("AIRBORNE")
	pass
	
func exiting():
	#model.stop_anim()
	body.gravity_scale = 1.0
	pass

