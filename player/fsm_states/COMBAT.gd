extends BPBFSM_STATE

var light = -1
var heavy = -1
var left = false
func entering():
	if blackboard["combat_attack_is_light"]:
		light = wrapi(light + 1, 0, 2)
		blackboard["combat_attack_anim_idx"] = light
		blackboard["combat_attack_from_left"] = left
		left = not left
	else:
		heavy = wrapi(heavy + 1, 0, 1)
		blackboard["combat_attack_anim_idx"] = heavy
		blackboard["combat_attack_from_left"] = left
		left = not left
	set_child_next_state("ATTACK")
	body.direction_zeroed()
	
func working(_delta):
	pass
	
func exiting():
	pass

