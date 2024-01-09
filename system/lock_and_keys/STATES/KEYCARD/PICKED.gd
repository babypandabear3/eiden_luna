extends BPBFSM_STATE


func entering():
	model.hide()
	blackboard.colshape.disabled = true
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

