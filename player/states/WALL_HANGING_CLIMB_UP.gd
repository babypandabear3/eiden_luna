extends HFSM_STATE


var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var timer := 0.0
var timer_max := 1.0

func entering():
	pass
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	body.hanging_override(blackboard["hanging_direction"])
	sensor = blackboard["sensor"]
	blackboard["climb_origin"] = body.global_position
	blackboard["climb_target_mid"] = body.global_position + (body.gravity_direction * -1.25)
	blackboard["climb_target"] = sensor.ray_ledge_collision_point() + (body.gravity_direction * -0.9)
	
	model.play_anim("HANGING_CLIMB_UP")

	timer = 0.0
	var tween = create_tween()
	tween.tween_property(body, "global_position", blackboard["climb_target_mid"], 0.5)
	tween.tween_property(body, "global_position", blackboard["climb_target"], 0.5)
	
func working(_delta):
	timer += _delta
	if timer >= timer_max:
		set_next_state("WALL_HANGING")
		blackboard["wall_hanging_exit_to"] = "GROUNDED"
	
func exiting():
	body.load_default_vars()
	pass

