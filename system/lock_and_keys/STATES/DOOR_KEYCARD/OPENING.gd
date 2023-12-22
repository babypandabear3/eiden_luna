extends HFSM_STATE

var model : Lock_N_Key_Model_Door
func entering():
	model = blackboard["model"]
	model.opening()
	
func working(_delta):
	if not blackboard.open_door:
		set_next_state("CLOSING")
	
func exiting():
	pass
