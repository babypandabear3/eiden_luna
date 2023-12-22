extends HFSM_STATE

@export var anim :String = "ATK_L0"
@export var timeout :float = 0.8
var body : Body
var model : Model_Generic
var camera : Camera3D
var sensor : PlayerSensor
var timer := 0.8
var receive_input = 0.02

func entering():
	body = blackboard.body
	model = blackboard.model
	camera = get_viewport().get_camera_3d()
	sensor = blackboard["sensor"]
	timer = 0
	body.root_motion_entering()
	body.direction = Vector3.ZERO
	model.play_anim(anim)
	get_parent().update_atk(anim)
	
	
func working(_delta):
	timer += _delta
	if timer > timeout:
		blackboard["combat_exit_to"] = "PLAYER_CONTROL"
		return
		
	if timer >= receive_input:
		if Input.is_action_just_pressed("attack_light"):
			var next_state = get_parent().get_next_atk_l()
			set_next_state(next_state)
			model.set_animplayer_blendtime(clamp(timeout - timer, 0.2, timeout))
			
		if Input.is_action_just_pressed("attack_heavy"):
			var next_state = get_parent().get_next_atk_h()
			set_next_state(next_state)
			model.set_animplayer_blendtime(clamp(timeout - timer, 0.2, timeout))
			
	body.set_root_motion_velocity(model.get_root_motion_velocity())
	
func exiting():
	body.walk_entering()
	

