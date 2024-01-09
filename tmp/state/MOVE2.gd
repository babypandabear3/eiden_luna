extends BPBFSM_STATE

var time : float = 3.0

func entering():
	time = 3.0
	
func working(_delta):
	main.position.x -= 2.0 * _delta
	
	time -= _delta
	if time < 0:
		set_next_state("MOVE1")
	
func exiting():
	pass

