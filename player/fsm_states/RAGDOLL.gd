extends BPBFSM_STATE

@onready var ragdoll_i = preload("res://player/player_ragdoll.tscn")

var bring_body_back = false

var prison : Vector3 = Vector3(0, 0,-2048)

func entering():
	if weakref(blackboard.get("ragdoll")).get_ref():
		return
		
	bring_body_back = false
	var push_force = (blackboard["ragdoll_pushed_by"].global_position.direction_to(model.global_position )) * blackboard["ragdoll_push_force"]
	
	blackboard["ragdoll"] = ragdoll_i.instantiate()
	owner.owner.add_child(blackboard["ragdoll"])
	var ragdoll_transform = body.global_transform
	var model_basis = model.global_basis
	
	blackboard["ragdoll"].start_ragdoll(ragdoll_transform, model_basis, push_force)
	
	body.fly_entering()
	body.direction = Vector3.ZERO
	model.hide()
	
	#FOLLOWING 3 LINES NEEDED TO SETUP FIRST FRAME ANIMATION
	model.play_anim("JUMP_2ND")
	await get_tree().physics_frame
	model.stop_anim()
	
func working(_delta):
	if not weakref(blackboard.get("ragdoll")).get_ref():
		return
	
	body.global_position = blackboard["ragdoll"].global_position
	
	if blackboard["ragdoll"].start_getting_up:
		blackboard["get_up_direction"] = blackboard["ragdoll"].get_model_direction(body.up_direction)
		blackboard["ragdoll"].hide()
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "GET_UP"])
	
	
func exiting():
	pass

