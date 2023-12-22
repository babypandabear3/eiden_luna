extends HFSM_STATE


var model : Lock_N_Key_Model_Door
func entering():
	model = blackboard["model"]
	model.closing()
	
func working(_delta):
	if blackboard.open_door:
		set_next_state("OPENING")
	pass
	
func exiting():
	pass

