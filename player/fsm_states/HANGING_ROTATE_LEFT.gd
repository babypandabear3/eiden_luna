extends BPBFSM_STATE

var timer_length : float = 1.0
var timer : float = 0.0
var dir_0 : Vector3
var dir_1 : Vector3

var phase : int = 0
var sensor : PlayerSensor

func entering():
	body.fly_entering()
	sensor = blackboard["sensor"]
	dir_0 = model.global_basis.x
	dir_1 = model.global_basis.z
	timer = timer_length
	phase = 0
	model.slerp_direction(blackboard["hanging_rotate_direction"])
	body.SPEED = 4.0
	
	
func working(_delta):
	model.play_anim("HANGING-MLEFT")
	if phase == 0:
		body.direction = dir_0
		if not sensor.is_ray_body_side_left_colliding():
			phase = 1
			body.SPEED = 2.0
			
	else:
		body.direction = dir_1
	
	timer -= _delta
	if timer < 0.0:
		blackboard["hanging_direction"] = sensor.ray_chest_normal()
		set_next_state("HANGING")
	pass
	
func exiting():
	body.walk_entering()
	pass

