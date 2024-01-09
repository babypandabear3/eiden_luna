extends BPBFSM_STATE

func entering():
	main = main as Area3D
	if not main.is_connected("body_entered", _on_body_entered):
		main.connect("body_entered", _on_body_entered)
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

func _on_body_entered(_body):
	set_next_states_from_root(["WORK", "UP_DOWN"])
	
