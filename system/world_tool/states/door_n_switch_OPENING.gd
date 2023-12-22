extends HFSM_STATE

var main : Node3D
var door : AnimatableBody3D

func entering():
	main = blackboard["main"]
	door = main.find_children("*", "AnimatableBody3D").front()
	var tween = create_tween()
	tween.tween_property(door, "position", Vector3(0,5,0), 0.3)
	await get_tree().create_timer(0.3).timeout
	set_next_state("OPENED")
	
func working(_delta):
	pass
	
func exiting():
	pass

