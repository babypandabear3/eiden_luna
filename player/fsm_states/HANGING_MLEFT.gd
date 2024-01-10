extends BPBFSM_STATE


var camera : Camera3D
var sensor : PlayerSensor
var timeout := 0.9
var timer = 0.0

func entering():
	body.fly_entering()
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	model.play_anim("HANGING-MLEFT")
	timer = timeout # model.get_anim_length("HANGING-MRIGHT")
	body.SPEED = 4.0
	
		
func working(_delta):
	body.direction = -sensor.ray_chest_normal() + model.global_transform.basis.x
	model.set_direction(-sensor.ray_chest_normal())
	body.SPEED *= _delta * 0.96 * body.physic_fps
	if sensor.ray_ledge_left_colliding() :
		body.SPEED = 0.0
		
	timer -= _delta
	if timer <= 0.0:
		set_next_state("HANGING")
		
	if not (sensor.get_hanging_rotate_left_normal().is_equal_approx(sensor.get_hanging_rotate_right_normal())):
		blackboard["hanging_rotate_direction"] = -sensor.get_hanging_rotate_left_normal()
		set_next_state("HANGING_ROTATE_LEFT")
		
	if not sensor.ray_chest_colliding():
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "FALL"])
		
		
	if sensor.ray_head_colliding():
		set_next_state("HANGING")
	#	

func exiting():
	body.load_default_vars()

