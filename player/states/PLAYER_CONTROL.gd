extends HFSM_STATE


func entering():
	if not blackboard.get("wallrun_energy"):
		blackboard["wallrun_energy"] = 0.0
	blackboard["player_control_exit_to"] = ""
	
func working(_delta):
	if not blackboard["player_control_exit_to"] == "":
		set_next_state(blackboard["player_control_exit_to"])
	
func exiting():
	pass

