extends BPBFSM_STATE

var camera : Camera3D
var sensor : PlayerSensor
var in_state_timer = 0.0

func entering():
	body.fly_entering()
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	model.play_anim("HANGING")
	in_state_timer = 0.0
	body.SPEED = 1.0
	
	
func working(_delta):
	in_state_timer += _delta
	
	body.direction = -sensor.ray_chest_normal()
	model.set_direction(-sensor.ray_chest_normal())
	var adjust = sensor.get_ledge_hanging_v_adjustment()
	# NO IDEA WHY THIS IS NEEDED 
	# BUT WITHOUT IT BODY ADJUSTMENT CAN SOMETIMES SEND PLAYER TO THE MOON
	if adjust < 1.0: 
		body.global_position += body.gravity_direction.normalized() * adjust * _delta * 30
		
	if in_state_timer < 0.1:
		return
		
	if Input.is_action_just_pressed("hanging_jump"):
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "WALLJUMP"])
		pass
			
	if Input.is_action_just_pressed("hanging_climb_up"):
		set_next_state("HANGING_CLIMB_UP")
		
	if Input.is_action_just_pressed("hanging_release"):
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "FALL"])
		
	if sensor.ray_head_colliding():
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "FALL"])
	
	var dir = Input.get_axis("move_left", "move_right")
	if not is_zero_approx(dir) :
		if dir < 0:
			if not sensor.ray_ledge_left_colliding():
				set_next_state("HANGING_MLEFT")
		else:
			if not sensor.ray_ledge_right_colliding():
				set_next_state("HANGING_MRIGHT")
	
	if not sensor.ray_chest_colliding():
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "FALL"])
		

func exiting():
	body.walk_entering()
	pass

