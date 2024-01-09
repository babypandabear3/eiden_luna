extends BPBFSM_STATE

var camera : Camera3D
var sensor : PlayerSensor
var timeout := 0.5

func entering():
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	
	body.fly_entering()
	var dot_product := -model.global_transform.basis.z.dot(sensor.ray_chest_normal())
	if dot_product > 0.75:
		blackboard["wallrun_dir"] = 0
	else:
		var dot_side = model.global_transform.basis.x.dot(sensor.ray_chest_normal())
		if dot_side > 0:
			blackboard["wallrun_dir"] = 1
		else:
			blackboard["wallrun_dir"] = -1
			
	if blackboard["wallrun_dir"] == 0:
		set_child_next_state("WALLRUN_UP")
	elif blackboard["wallrun_dir"] == -1:
		set_child_next_state("WALLRUN_LEFT")
	elif blackboard["wallrun_dir"] == 1:
		set_child_next_state("WALLRUN_RIGHT")
		
func working(_delta):
	pass
	
func exiting():
	body.walk_entering()
	body.velocity = Vector3.ZERO
	model.set_anim_speed(1.0)
	pass

