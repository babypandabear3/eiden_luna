class_name Model_Generic
extends Node3D

@export var z_as_forward :bool = true
@export var rotation_speed := 0.5
@export var default_anim :String = "IDLE"
var last_direction := Vector3.ZERO
var anim_player : AnimationPlayer
var parent_node
var current_animation = ""

func _ready():
	anim_player = find_children("*", "AnimationPlayer")[0]
			
	if anim_player:
		anim_player.playback_default_blend_time = 0.1
		anim_player.play(default_anim)
	call_deferred("late_ready")
	
func reset_animplayer_blendtime():
	anim_player.playback_default_blend_time = 0.1
	
func set_animplayer_blendtime(_par : float = 0.0):
	anim_player.playback_default_blend_time = _par
		
func late_ready():
	parent_node = get_parent()
		
func restart_anim(_par:String):
	seek_anim()
	play_anim(_par)
	
func play_anim(_par:String):
	if anim_player:
		anim_player.play(_par)
		
		
func seek_anim(_par:float=0.0):
	if anim_player:
		anim_player.seek(_par)
	
func queue_anim(_par:String):
	if anim_player:
		anim_player.queue(_par)
		
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
		
func get_root_motion_velocity():
	if anim_player.has_method("get_inertialized_root_motion_velocity"):
		#return anim_player.get_inertialized_root_motion_velocity().rotated(global_basis.y, rotation.y)
		return global_basis.get_rotation_quaternion() * anim_player.get_inertialized_root_motion_velocity()
	else:
		return Vector3.ZERO
		
	
func set_direction(_dir:Vector3):
	slerp_direction(_dir)
	
func slerp_direction(_dir:Vector3):
	if is_zero_approx(_dir.length_squared()):
		return
	if _dir.normalized().is_equal_approx(last_direction):
		return
	else:
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
		
		var tween = create_tween()
		tween.tween_method(Callable(self, "slerp_basis").bind(old_bas, new_bas), 0.0, 1.0, rotation_speed)
		

func slerp_basis(weight:float, old_bas:Basis, new_bas:Basis):
	global_transform.basis = old_bas.slerp(new_bas, weight)

func set_immediate_direction(_dir : Vector3):
	if is_zero_approx(_dir.length_squared()):
		return
	if _dir.normalized().is_equal_approx(last_direction):
		return
	else:
		last_direction = _dir
		var new_bas := global_transform.basis
		new_bas.y = parent_node.global_transform.basis.y
		if z_as_forward:
			new_bas.z = _dir.slide(new_bas.y).normalized()
			new_bas.x = new_bas.y.cross(new_bas.z)
		else:
			new_bas.z = -_dir.slide(new_bas.y).normalized()
			new_bas.x = new_bas.y.cross(new_bas.z)
		
		new_bas = new_bas.orthonormalized()
		global_transform.basis = new_bas
