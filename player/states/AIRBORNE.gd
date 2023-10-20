extends HFSM_STATE

var body : CharacterBody3D
var model : Node3D
var camera : Camera3D

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	model.queue_anim("AIRBORNE")
	
func working(_delta):
	pass
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("jump"):
		body.try_jump()
		
	var camera_basis = camera.global_transform.basis
	camera_basis.z = camera_basis.z.slide(camera_basis.y).normalized()
	camera_basis.x = camera_basis.y.cross(camera_basis.z)
	
	var direction = (camera_basis.x * dir.x) + (camera_basis.z * dir.y)
	body.direction = direction
	model.set_direction(direction)
	
	if body.jump_count < 1:
		set_next_state("GROUNDED")
		
	if Input.is_action_just_pressed("jump"):
		if body.try_jump():
			set_next_state("JUMP_2ND")
	
func exiting():
	pass

