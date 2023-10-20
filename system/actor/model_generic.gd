class_name Model_Generic
extends Node3D

@export var default_anim :String = "IDLE"
var last_direction := Vector3.ZERO
var anim_player : AnimationPlayer
func _ready():
	anim_player = find_children("*", "AnimationPlayer")[0]
			
	if anim_player:
		anim_player.playback_default_blend_time = 0.1
		anim_player.play(default_anim)
		
func play_anim(_par:String):
	if anim_player:
		anim_player.play(_par)
		
func queue_anim(_par:String):
	if anim_player:
		anim_player.queue(_par)
		
func set_anim_speed(_par:float):
	if anim_player:
		anim_player.speed_scale = _par
		
func set_direction(_dir:Vector3):
	if is_zero_approx(_dir.length_squared()):
		return
	if _dir.normalized().is_equal_approx(last_direction):
		return
	else:
		last_direction = _dir
		var old_bas := global_transform.basis
		var new_bas := global_transform.basis
		new_bas.z = -_dir
		new_bas.x = new_bas.y.cross(new_bas.z)
		new_bas = new_bas.orthonormalized()
		var tween = create_tween()
		
		tween.tween_method(Callable(self, "slerp_basis").bind(old_bas, new_bas), 0.0, 1.0, 0.5)
		
func slerp_basis(weight:float, old_bas:Basis, new_bas:Basis):
	global_transform.basis = old_bas.slerp(new_bas, weight)

