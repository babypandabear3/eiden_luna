extends HFSM_STATE

var airborne := 0.0
var body : Body
var model : Model_Generic
var camera : Camera3D
var in_state_timer = 0.0
var sensor : PlayerSensor

func entering():
	airborne = 0.0
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	in_state_timer = 0.0
	sensor = blackboard["sensor"]
	if not sensor.is_connected("jump_pod_entered", _jump_pod_entered):
		sensor.jump_pod_entered.connect(_jump_pod_entered)
	if not sensor.is_connected("punched_to_ragdoll_entered", _punched_to_ragdoll_entered):
		sensor.punched_to_ragdoll_entered.connect(_punched_to_ragdoll_entered)
		
		
		
	DEBUG._print("grounded")
	
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
		set_next_state("AIRBORNE")
		
	if body.is_on_wall() and sensor.wallrun_is_possible() and Input.is_action_pressed("special_move") and blackboard["wallrun_energy"] > 0.0:
		set_next_state("WALLRUN")
		
	if Input.is_action_just_pressed("roll"):
		set_next_state("ROLL")
		
	if Input.is_action_just_pressed("attack_light"):
		blackboard["player_control_exit_to"] = "COMBAT"
		blackboard["combat_selected_attack"] = "L0"
	if Input.is_action_just_pressed("attack_heavy"):
		blackboard["player_control_exit_to"] = "COMBAT"
		blackboard["combat_selected_attack"] = "H0"
		
func exiting():
	model.set_anim_speed(1.0)

func _jump_pod_entered():
	if body.try_jump():
		set_next_state("JUMP")
	body.apply_central_impulse(body.gravity_direction * -1.0)

func _punched_to_ragdoll_entered(area):
	print(area, area.global_position)
	blackboard["player_control_exit_to"] = "HURT"
	blackboard["hurt_enter_into"] = "RAGDOLL"
	blackboard["ragdoll_pushed_by"] = area
	blackboard["ragdoll_push_force"] = area.get_push_force()
	
