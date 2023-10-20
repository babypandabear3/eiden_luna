extends HFSM_STATE

var body
var model
var camera
func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	
func working(_delta):
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("jump"):
		body.try_jump()
		
	var camera_basis = camera.global_transform.basis
	camera_basis.z = camera_basis.z.slide(camera_basis.y).normalized()
	camera_basis.x = camera_basis.y.cross(camera_basis.z)
	
	var direction = (camera_basis.x * dir.x) + (camera_basis.z * dir.y)
	body.direction = direction
	model.set_direction(direction)
	
	if body.is_on_floor():
		if body.direction.is_equal_approx(Vector3.ZERO):
			model.play_anim("IDLE")
		else:
			model.play_anim("RUN")
	else:
		model.play_anim("AIRBORNE")
	
func exiting():
	pass

