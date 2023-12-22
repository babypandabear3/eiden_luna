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
	model.play_anim("WALLRUN_UP")
	model.set_anim_speed(1.7)
	
func working(_delta):
	blackboard["wallrun_energy"] -= _delta
	body.direction = -body.gravity_direction
	model.set_direction(-sensor.ray_chest_normal())
	
	if blackboard["wallrun_energy"] <= 0:
		set_next_state("WALLRUN_UP")
		blackboard["wallrun_exit_to"] = "AIRBORNE"
		
	if Input.is_action_just_released("special_move"):
		set_next_state("WALLRUN_UP")
		blackboard["wallrun_exit_to"] = "AIRBORNE"
	
	if sensor.hanging_is_possible(): 
		blackboard["hanging_direction"] = sensor.ray_chest_normal()
		set_next_state("WALLRUN_UP")
		blackboard["wallrun_exit_to"] = "HANGING_ON_LEDGE"
		model.play_anim("HANGING")
	
	if Input.is_action_just_pressed("jump"):
		blackboard["wallrun_exit_to"] = "WALLJUMP"
			
func exiting():
	pass

