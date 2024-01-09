extends BPBFSM_STATE

func entering():
	model.play_anim("JUMP_2ND")
	model.set_anim_speed(1.4)
	await get_tree().process_frame
	
func working(_delta):
	set_next_state("AIRBORNE")
	pass
	
	
func exiting():
	pass

