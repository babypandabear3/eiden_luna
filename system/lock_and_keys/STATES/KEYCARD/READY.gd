extends HFSM_STATE

var rotation_speed = deg_to_rad(180.0)
func entering():
	pass
	
func working(_delta):
	blackboard.model.rotate_y(_delta * rotation_speed)
	if blackboard["taken_by_player"]:
		set_next_state("PICKED")
	
	
func exiting():
	pass

