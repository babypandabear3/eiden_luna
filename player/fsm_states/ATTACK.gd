extends BPBFSM_STATE

var light_left = ["ATK_LLeft0", "ATK_LLeft1", "ATK_LLeft2"]
var light_right = ["ATK_LRight0", "ATK_LRight1", "ATK_LRight2"]
var heavy_left = ["ATK_HLeft0", "ATK_HLeft1"]
var heavy_right = ["ATK_HRight0", "ATK_HRight1"]

var timer : float = 100.0

func entering():
	var anim_list = []
	if blackboard["combat_attack_is_light"]:
		if blackboard["combat_attack_from_left"]:
			anim_list = light_left
		else:
			anim_list = light_right
	else:
		if blackboard["combat_attack_from_left"]:
			anim_list = heavy_left
		else:
			anim_list = heavy_right
		
	var anim_idx = blackboard["combat_attack_anim_idx"]
	var anim = anim_list[anim_idx]
	model.play_anim(anim)
	timer = model.get_anim_length(anim)
	DEBUG._print(anim + " length = " + str(timer))
	pass
	
func working(_delta):
	body.set_root_motion_velocity(model.get_root_motion_velocity())
	timer -= _delta
	if timer < 0.0:
		set_next_states_from_root(["GAMEPLAY", "PLAYER_CONTROL", "GROUNDED"])
	
func exiting():
	pass

