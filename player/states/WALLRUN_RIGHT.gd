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
	sensor = blackboard["sensor"]
	model.play_anim("WALLRUN_RIGHT")
	model.set_anim_speed(1.7)
	
func working(_delta):
	blackboard["wallrun_energy"] -= _delta * 0.5
	
	var direction = model.global_transform.basis.z.slide(sensor.ray_chest_normal())
	body.direction = direction
	model.set_direction(direction)
	
	if blackboard["wallrun_energy"] <= 0:
		set_next_state("WALLRUN_UP")
		blackboard["wallrun_exit_to"] = "AIRBORNE"
		
	if Input.is_action_just_released("special_move"):
		set_next_state("WALLRUN_UP")
		blackboard["wallrun_exit_to"] = "AIRBORNE"
	
	if Input.is_action_just_pressed("jump"):
		blackboard["wallrun_exit_to"] = "WALLJUMP"
	
func exiting():
	pass

