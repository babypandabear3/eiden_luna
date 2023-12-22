extends HFSM_STATE


func entering():
	if not blackboard.get("door_state_to"):
		blackboard["door_state_to"] = ""
	
func working(_delta):
	if not blackboard["door_state_to"] == "":
		state_next = (blackboard["door_state_to"])
		blackboard["door_state_to"] = ""
	
func exiting():
	pass

