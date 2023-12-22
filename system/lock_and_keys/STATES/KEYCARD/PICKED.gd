extends HFSM_STATE


func entering():
	blackboard.model.hide()
	blackboard.colshape.disabled = true
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

