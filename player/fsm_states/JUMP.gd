extends BPBFSM_STATE

func entering():
	model.play_anim("JUMP")
	pass
	
func working(_delta):
	set_next_state("AIRBORNE")
	
func exiting():
	pass

