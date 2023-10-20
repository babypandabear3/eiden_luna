extends HFSM_STATE

var body : CharacterBody3D
var model : Node3D
var camera : Camera3D

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	model.play_anim("JUMP_2ND")
	print("JUMP_2ND")
	pass
	
func working(_delta):
	set_next_state("AIRBORNE")
	pass
	
func exiting():
	pass

