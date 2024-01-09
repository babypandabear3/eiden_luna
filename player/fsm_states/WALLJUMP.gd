extends BPBFSM_STATE

var camera : Camera3D
var sensor : PlayerSensor
var wall_normal = Vector3.ZERO
var timer : float = 0.0
func entering():
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	
	var colinfo : KinematicCollision3D = body.get_last_slide_collision()
	if colinfo:
		wall_normal = colinfo.get_normal()
	else:
		wall_normal = sensor.ray_chest_normal()
	body.direction = -wall_normal
	body.horizontal_speed_scale = 0.0
	body.vertical_speed_scale = 0.0
	model.set_direction(-wall_normal)
	model.play_anim("WALLJUMP")
	timer = 0.27
	blackboard["airborne_fwd_direction"] = wall_normal
	
func working(_delta):
	timer -= _delta
	if timer <= 0.0:
		body.direction = wall_normal
		model.set_direction(wall_normal)
		body.jump_count = 0
		body.try_jump()
		set_next_state("AIRBORNE_FWD")
	pass
	
func exiting():
	body.horizontal_speed_scale = 1.0
	body.vertical_speed_scale = 1.0
