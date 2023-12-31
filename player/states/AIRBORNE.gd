extends HFSM_STATE

var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var in_state_timer = 0.0
var touch_wall = false

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	
	#model.queue_anim("AIRBORNE")
	in_state_timer = 0.0
	if not sensor.is_connected("jump_pod_entered", _jump_pod_entered):
		sensor.jump_pod_entered.connect(_jump_pod_entered)
	touch_wall = false
	
	if blackboard.get("airborne_try_jump"):
		if blackboard["airborne_try_jump"]:
			body.jump_count = 0
			body.try_jump()
			blackboard["airborne_try_jump"] = false
	
	DEBUG._print("airborne")
	
func working(_delta):
	in_state_timer += _delta
	
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("jump"):
		body.try_jump()
		
	var camera_basis = camera.global_transform.basis
	camera_basis.z = camera_basis.z.slide(camera_basis.y).normalized()
	camera_basis.x = camera_basis.y.cross(camera_basis.z)
	
	var direction = (camera_basis.x * dir.x) + (camera_basis.z * dir.y)
	body.direction = direction
	model.set_direction(direction)
	
	if body.jump_count < 1 and body.is_on_floor():
		set_next_state("GROUNDED")
		
	if Input.is_action_just_released("jump"):
		body.jump_released()
		
	if body.is_on_wall():
		if not touch_wall:
			model.play_anim("HANGING-ENTER")
			#model.queue_anim("AIRBORNE")
			touch_wall = true
	else:
		touch_wall = false
		model.queue_anim("AIRBORNE")
		#model.play_anim("AIRBORNE")
		
	if Input.is_action_just_pressed("jump"):
		if body.is_on_wall():
			set_next_state("WALLJUMP")
		else:
			if body.try_jump():
				set_next_state("JUMP_2ND")
				
	if model.get_current_anim() == "AIRBORNE":
		model.set_anim_speed(1.0)
		
	### ledge detection
	
	if sensor.hanging_is_possible() and in_state_timer > 0.4: 
		blackboard["hanging_direction"] = sensor.ray_chest_normal()
		set_next_state("HANGING_ON_LEDGE")
		
	if body.is_on_wall() and sensor.wallrun_is_possible() and Input.is_action_pressed("special_move")  and blackboard["wallrun_energy"] > 0.0:
		set_next_state("WALLRUN")
		
	if sensor.can_wall_hanging() and in_state_timer > 0.4: 
		blackboard["hanging_direction"] = sensor.ray_chest_normal()
		set_next_state("WALL_HANGING")
		print("can_wall_hanging")
		
func exiting():
	pass

func _jump_pod_entered():
	if body.try_jump():
		set_next_state("JUMP")
	body.apply_central_impulse(body.gravity_direction * -1.0)
