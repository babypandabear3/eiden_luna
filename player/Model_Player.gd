class_name Model_Player
extends Model_Generic

var latest_finished_anim = ""
var set_direction_count := 0
#var skeleton : Skeleton3D
#var getup : Skeleton_Getup_Maker
var ragdoll

func _ready():
	anim_player = find_children("*", "AnimationPlayer").front() as AnimationPlayer
	anim_player.playback_default_blend_time = 0.1
	anim_player.animation_finished.connect(_animation_finished)
	ragdoll = find_children("*", "BPBRagdoll").front() as BPBRagdoll
	#skeleton = find_children("*", "Skeleton3D").front() as Skeleton3D
	#getup = find_children("*", "Skeleton_Getup_Maker").front() as Skeleton_Getup_Maker
	call_deferred("late_ready")

		
func late_ready():
	parent_node = get_parent()
	
func restart_anim(_par:String):
	seek_anim()
	play_anim(_par)
	
func play_anim(_par:String):
	if anim_player:
		if anim_player.has_method("request_animation"):
			if _par != current_animation:
				var anim_name = "eiden_animation_library/" + _par
				anim_player.request_animation(anim_name, 0.0)
		else:
			anim_player.play(_par)
	current_animation = _par
		
func seek_anim(_par:float=0.0):
	if anim_player:
		anim_player.seek(_par)
	
func queue_anim(_par:String):
	await anim_player.animation_finished
	play_anim(_par)
	
		
func stop_anim():
	if anim_player:
		anim_player.stop()
		
func get_current_anim():
	return anim_player.current_animation
	
func get_anim_length(_par:String):
	if anim_player:
		return anim_player.get_animation(_par).length
	else:
		return 0.0
		
func set_anim_speed(_par:float):
	if anim_player:
		anim_player.speed_scale = _par
		
func set_direction(_dir:Vector3):
	if is_zero_approx(_dir.length_squared()):
		return
	
	
	last_direction = _dir
	var old_bas := global_transform.basis
	var new_bas := global_transform.basis
	new_bas.y = parent_node.global_transform.basis.y
	if z_as_forward:
		new_bas.z = _dir.slide(new_bas.y).normalized()
		new_bas.x = new_bas.y.cross(new_bas.z)
	else:
		new_bas.z = -_dir.slide(new_bas.y).normalized()
		new_bas.x = new_bas.y.cross(new_bas.z)
	
	new_bas = new_bas.orthonormalized()
	slerp_basis(0.1, old_bas, new_bas)
		
		

func slerp_basis(weight:float, old_bas:Basis, new_bas:Basis):
	global_transform.basis = old_bas.slerp(new_bas, weight)

func _animation_finished(_anim_name):
	latest_finished_anim = _anim_name
	pass

func start_ragdoll():
	if anim_player:
		anim_player.stop()
	ragdoll.start_physical_simulation()
	
func kick_ragdoll(force : Vector3):
	ragdoll.apply_impulse(force)
