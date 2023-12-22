extends HFSM_STATE


func entering():
	blackboard["model"].start_ragdoll()
	blackboard["body"].direction = Vector3.ZERO
	
	var push_force = (blackboard["ragdoll_pushed_by"].global_position.direction_to(blackboard["model"].global_position )) * blackboard["ragdoll_push_force"]
	blackboard["model"].kick_ragdoll(push_force)
	
func working(_delta):
	pass
	
func exiting():
	pass
