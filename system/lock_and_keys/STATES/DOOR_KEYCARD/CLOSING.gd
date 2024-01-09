extends BPBFSM_STATE


func entering():
	model.closing()
	
func working(_delta):
	if blackboard.open_door:
		set_next_state("OPENING")
	pass
	
func exiting():
	pass
