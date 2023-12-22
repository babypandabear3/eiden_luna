extends HFSM_STATE

var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var in_state_timer = 0.0

func entering():
	pass
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	model.play_anim("HANGING")
	in_state_timer = 0.0
	
	
func working(_delta):
	model.play_anim("HANGING")
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
		blackboard["hanging_exit_to"] = "WALLJUMP"
			
	if Input.is_action_just_pressed("hanging_climb_up"):
		set_next_state("HANGING_CLIMB_UP")
		
	if Input.is_action_just_pressed("hanging_release"):
		blackboard["hanging_exit_to"] = "AIRBORNE"
		model.play_anim("AIRBORNE")
		
	if sensor.ray_head_colliding():
		blackboard["hanging_exit_to"] = "AIRBORNE"
	
	var dir = Input.get_axis("move_left", "move_right")
	if not is_zero_approx(dir) :
		if dir < 0:
			if not sensor.ray_ledge_left_colliding():
				set_next_state("HANGING_MLEFT")
		else:
			if not sensor.ray_ledge_right_colliding():
				set_next_state("HANGING_MRIGHT")
	
	if not sensor.ray_chest_colliding():
		#model.stop_anim()
		blackboard["hanging_exit_to"] = "AIRBORNE"

func exiting():
	pass

