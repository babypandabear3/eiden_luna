extends BPBFSM_STATE

func entering():
	body.walk_entering()
	body.velocity = Vector3.ZERO
	model.set_anim_speed(1.0)
	model.play_anim("AIRBORNE")
	set_next_state("AIRBORNE")
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

