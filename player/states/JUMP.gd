extends HFSM_STATE

var body : Body
var model : Model_Generic
var camera : Camera3D

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	model.play_anim("JUMP")
	
func working(_delta):
	set_next_state("AIRBORNE")
	pass
	
func exiting():
	pass

