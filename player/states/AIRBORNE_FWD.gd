extends HFSM_STATE

var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var in_state_timer = 0.0

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	body.walljump_override(blackboard.airborne_fwd_direction)
	model.set_direction(blackboard.airborne_fwd_direction)
	model.play_anim("AIRBORNE_FWD")
	in_state_timer = 0.0
	if not sensor.is_connected("jump_pod_entered", _jump_pod_entered):
		sensor.jump_pod_entered.connect(_jump_pod_entered)
	
func working(_delta):
	model.set_direction(blackboard.airborne_fwd_direction)
	if body.jump_count < 1 and body.is_on_floor():
		set_next_state("GROUNDED")
	
	if Input.is_action_just_pressed("jump"):
		if body.is_on_wall():
			set_next_state("WALLJUMP")
		else:
			if body.try_jump():
				set_next_state("JUMP_2ND")
				
	if body.is_on_wall():
		set_next_state("WALL_LANDED")
		
	if sensor.hanging_is_possible() and in_state_timer > 0.5: 
		blackboard["hanging_direction"] = sensor.ray_chest_normal()
		set_next_state("HANGING_ON_LEDGE")
		
	if body.is_on_wall() and sensor.wallrun_is_possible() and Input.is_action_pressed("special_move") and blackboard["wallrun_energy"] > 0.0:
		set_next_state("WALLRUN")
				
	if model.get_current_anim() == "AIRBORNE_FWD":
		model.set_anim_speed(1.0)
		
	in_state_timer += _delta
	
func exiting():
	pass

func _jump_pod_entered():
	if body.try_jump():
		set_next_state("JUMP")
	body.apply_central_impulse(body.gravity_direction * -1.0)
