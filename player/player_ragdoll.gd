extends Node3D

@onready var armature : Node3D = $Armature_male
@onready var ragdoll : BPBRagdoll = $BPBRagdoll
@onready var animplayer : AnimationPlayer = $AnimationPlayer

var v0 : Vector3
var v1 : Vector3
var v2 : Vector3
var timer = 5.0
var get_up = false
var start_getting_up = false
var finish_getting_up = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var val = randf_range(1,10)
	v0 = Vector3(val, val, val)
	val *= 10
	v1 = Vector3(val, val, val)
	val *= 10
	v2 = Vector3(val, val, val)
	animplayer.animation_finished.connect(_animation_finished)

func get_ragdoll_rid():
	return ragdoll.get_ragdoll_rid()

func start_ragdoll(transf : Transform3D, model_basis : Basis,  force : Vector3 = Vector3.ZERO):
	global_transform = transf
	transf.origin.y -= 1.0
	transf.basis = model_basis
	armature.global_transform = transf
	ragdoll.global_transform = transf
	await get_tree().physics_frame
	ragdoll.start_physical_simulation()
	ragdoll.apply_impulse(force)
	
func _physics_process(delta):
	if get_up:
		pass
		queue_free() #DISABLE THIS LINE TO LET PLAYER GET UP BY MOVING BONES
		
	else:
		timer = clamp(timer - delta, -1, INF)
		v2 = v1
		v1 = v0
		v0 = ragdoll.get_hips_global_transform().origin
		var main_origin = v0
		main_origin.y += 0.9
		global_transform.origin = main_origin
		if v0.is_equal_approx(v1):
			if v0.is_equal_approx(v2):
				if timer < 0:
					get_up = true
					ragdoll.play_get_up()
					start_getting_up = true
					
func _animation_finished(_anim_name):
	$AnimationPlayer.stop()
	finish_getting_up = true
	await get_tree().create_timer(0.1).timeout
	hide()
	queue_free()
	pass

func get_body_follower():
	return $body_follower
	
func get_model_direction(up_direction):
	var hip = ragdoll.get_hips_global_transform()
	var spine = ragdoll.get_spine_global_transform()
	var dir = hip.origin.direction_to(spine.origin).slide(up_direction).normalized()
	if hip.basis.z.dot(up_direction) > 0:
		dir *= -1
	return dir
		

