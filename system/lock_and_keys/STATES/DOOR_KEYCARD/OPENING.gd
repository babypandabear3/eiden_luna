extends BPBFSM_STATE


func entering():
	model.opening()
	
func working(_delta):
	if not blackboard.open_door:
		set_next_state("CLOSING")
	
func exiting():
	pass
