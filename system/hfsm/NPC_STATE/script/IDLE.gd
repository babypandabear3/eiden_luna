extends HFSM_STATE

var timer := 0.0

func entering():
	timer = randf_range(3.0, 6.0)
	blackboard.body.direction = Vector3.ZERO
	blackboard.model.play_anim("IDLE")
	blackboard.model.set_anim_speed(2.0)
	
func working(_delta):
	timer -= _delta
	if timer < 0.0:
		set_next_state("WANDER")
		
	
	
func exiting():
	pass

