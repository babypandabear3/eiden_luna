extends HFSM_STATE

var main : Area3D

func entering():
	main = blackboard["main"]
	if not main.is_connected("area_entered", _on_area_entered):
		main.area_entered.connect(_on_area_entered)
	
func working(_delta):
	pass
	
func exiting():
	pass

func _on_area_entered(area):
	if area.is_in_group("player_foot_sensor"):
		set_next_state("ACTIVATED")

