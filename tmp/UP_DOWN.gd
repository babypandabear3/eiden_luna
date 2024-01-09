extends BPBFSM_STATE

var time : float = 3.0

func entering():
	time = 3.0
	
func working(_delta):
	time -= _delta
	if time < 0:
		set_next_states_from_root(["IDLE", "MOVE1"])
		
func exiting():
	pass

