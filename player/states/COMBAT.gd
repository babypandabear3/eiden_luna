extends HFSM_STATE

var atk_l = 0
var atk_h = 0

var max_atk_l = 2
var max_atk_h = 2

func entering():
	blackboard["combat_exit_to"] = ""
	state_next = blackboard["combat_selected_attack"]
	atk_l = 0
	atk_h = 0
	
	
func working(_delta):
	if not blackboard["combat_exit_to"] == "":
		set_next_state(blackboard["combat_exit_to"])
	
func exiting():
	blackboard.model.reset_animplayer_blendtime()
	blackboard.body.reset_root_motion_velocity()
	blackboard.body.walk_entering()
	pass

func update_atk(anim_name):
	if "_L" in anim_name:
		atk_l = wrapi(atk_l + 1, 0, max_atk_l)
	elif  "_H" in anim_name:
		atk_h = wrapi(atk_h + 1, 0, max_atk_l)
	
func get_next_atk_l():
	return "L" + str(atk_l)
	
func get_next_atk_h():
	return "H" + str(atk_h)
