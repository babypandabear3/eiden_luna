extends BPBFSM_STATE

func entering():
	body.walk_entering()
	model.show()
	model.play_anim("JUMP_2ND")
	model.seek_anim(0.15)
	var impulse = body.up_direction * 0.7
	body.apply_central_impulse(impulse)
	model.set_immediate_direction(blackboard["get_up_direction"])
	body.load_default_vars()
	pass
	
func working(_delta):
	if body.is_on_floor():
		set_next_state("AIRBORNE")
	pass
	
	
func exiting():
	pass
