extends BPBFSM_STATE

var airborne := 0.0
var in_state_timer = 0.0
var sensor : PlayerSensor
var camera : Camera3D

func entering():
	airborne = 0.0
	camera = get_viewport().get_camera_3d()
	in_state_timer = 0.0
	sensor = blackboard["sensor"]
	
	
func working(_delta):
	in_state_timer += _delta
	if in_state_timer > 0.5:
		blackboard["wallrun_energy"] = 1.0
		
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("jump"):
		if body.try_jump():
			set_next_state("JUMP")
		
	var camera_basis = camera.global_transform.basis
	camera_basis.z = camera_basis.z.slide(camera_basis.y).normalized()
	camera_basis.x = camera_basis.y.cross(camera_basis.z)
	
	var direction = (camera_basis.x * dir.x) + (camera_basis.z * dir.y)
	body.direction = direction
	
	model.set_direction(direction)
	
	if body.jump_count < 1:
		if body.direction.is_equal_approx(Vector3.ZERO):
			model.set_anim_speed(1.0)
			model.play_anim("IDLE")
		else:
			model.set_anim_speed(1.7)
			model.play_anim("RUN")
	else:
		set_next_state("FALL")
		
	if body.is_on_wall() and sensor.wallrun_is_possible() and Input.is_action_pressed("special_move") and blackboard["wallrun_energy"] > 0.0:
		set_next_state("WALLRUN")
		
	if Input.is_action_just_pressed("roll"):
		set_next_state("ROLL")
		
	if Input.is_action_just_pressed("attack_light"):
		set_next_states_from_root(["GAMEPLAY", "COMBAT"])
	#	blackboard["player_control_exit_to"] = "COMBAT"
		blackboard["combat_attack_is_light"] = true
	if Input.is_action_just_pressed("attack_heavy"):
		set_next_states_from_root(["GAMEPLAY", "COMBAT"])
		blackboard["combat_attack_is_light"] = false
	#	blackboard["player_control_exit_to"] = "COMBAT"
	#	blackboard["combat_selected_attack"] = "H0"
		
func exiting():
	model.set_anim_speed(1.0)



