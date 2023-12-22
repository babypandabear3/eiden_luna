extends HFSM_STATE

var main
func entering():
	main = blackboard.main
	main.door.do_step_open()
	set_next_state("INACTIVE")
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

