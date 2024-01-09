extends BPBFSM_STATE

func entering():
	var sensor = blackboard["sensor"]
	if not sensor.punched_to_ragdoll_entered.is_connected(_punched_to_ragdoll_entered):
		sensor.punched_to_ragdoll_entered.connect(_punched_to_ragdoll_entered)
		
	if not sensor.jump_pod_entered.is_connected(_jump_pod_entered):
		sensor.jump_pod_entered.connect(_jump_pod_entered)
		
	if not blackboard.get("wallrun_energy"):
		blackboard["wallrun_energy"] = 0.0
	
func working(_delta):
	pass
	
func exiting():
	pass

func _punched_to_ragdoll_entered(area):
	blackboard["ragdoll_pushed_by"] = area
	blackboard["ragdoll_push_force"] = area.get_push_force()
	set_next_states_from_root(["GAMEPLAY", "HURT", "RAGDOLL"])

func _jump_pod_entered():
	if body.try_jump():
		set_child_next_state("JUMP")
	body.apply_central_impulse(body.gravity_direction * -1.0)
