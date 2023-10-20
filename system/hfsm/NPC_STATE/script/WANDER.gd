extends HFSM_STATE

var wander_target := Vector3.ZERO
var agent : NavigationAgent3D
var next_path_position := Vector3.ZERO

func entering():
	blackboard.model.set_anim_speed(2.0)
	
	var dir = Vector3.ZERO
	dir.x = randf_range(-1,1)
	dir.z = randf_range(-1,1)
	var distance = randf_range(10, 16)
	dir = dir.normalized()
	wander_target = blackboard.body.global_position + (dir * distance)

	blackboard.model.play_anim("WALK")
	agent = blackboard["navagent"]
	agent.target_position = wander_target
	
	next_path_position = wander_target
	
	
func working(_delta):
	
	if not agent.get_next_path_position().is_equal_approx(next_path_position):
		var dir = blackboard["body"].global_position.direction_to( agent.get_next_path_position() ).normalized()
		next_path_position = agent.get_next_path_position()
		blackboard.body.direction = dir
		blackboard.model.set_direction(dir)

	
	if agent.is_target_reached():
		set_next_state("IDLE")
		
	
	
func exiting():
	pass

