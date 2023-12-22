extends HFSM_STATE


func entering():
	
	state_next = blackboard["hurt_enter_into"]
	blackboard["hurt_enter_into"] = ""
	blackboard["player_control_exit_to"] = ""
	
func working(_delta):
	pass
	
func exiting():
	pass

