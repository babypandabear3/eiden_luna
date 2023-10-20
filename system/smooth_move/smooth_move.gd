class_name Smooth_Move

extends Node3D

@export var target_path : NodePath
var target : Node3D
var update := false
var gt_prev :Transform3D
var gt_current :Transform3D
var do_interpolate := false

func _ready():
	top_level = true
	target = get_node_or_null(target_path)
	if not target:
		target = get_parent()
	global_transform = target.global_transform
	
	gt_prev = target.global_transform
	gt_current = target.global_transform

func update_transform():
	gt_prev = gt_current
	gt_current = target.global_transform
	update = false
	
func interpolate_transform():
	var f = clamp(Engine.get_physics_interpolation_fraction(), 0.0, 1.0)
	global_transform = gt_prev.interpolate_with(gt_current, f)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		call_deferred("update_transform")
	if do_interpolate:
		call_deferred("interpolate_transform")

func _physics_process(_delta):
	if not global_transform.is_equal_approx(target.global_transform):
		update = true
		do_interpolate = true
	else:
		do_interpolate = false
