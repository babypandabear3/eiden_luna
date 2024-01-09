extends BPBFSM_STATE


var camera : Camera3D
var sensor : PlayerSensor
var timeout := 0.0

func entering():
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	model.play_anim("HANGING-MLEFT")
	timeout = 1.0# model.get_anim_length("HANGING-MRIGHT")
	body.SPEED = 4.0
	
		
func working(_delta):
	body.direction = -sensor.ray_chest_normal() + model.global_transform.basis.x
	model.set_direction(-sensor.ray_chest_normal())
	body.SPEED *= _delta * 58
	if sensor.ray_ledge_left_colliding() :
		body.SPEED = 0.0
		
	timeout -= _delta
	if timeout <= 0.0:
		set_next_state("HANGING")
		
	if not sensor.ray_chest_colliding():
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "FALL"])
		
		
	if sensor.ray_head_colliding():
		set_next_state("HANGING")
	#	

func exiting():
	body.load_default_vars()

