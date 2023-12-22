@tool
class_name BoneAttachmentRemoteTransform
extends BoneAttachment3D

@export var update_in_editor : bool = false :
	set(value):
		update_editor_transform()
		update_in_editor = false
@export var remote_target : NodePath
@export var smoothing : bool = false

var update := false
var gt_prev :Transform3D
var gt_current :Transform3D
var do_interpolate := false

var target : Node3D = null

func _ready():
	pass
	
func update_transform():
	gt_prev = target.global_transform
	gt_current = global_transform
	update = false
	
func interpolate_transform():
	var f = clamp(Engine.get_physics_interpolation_fraction(), 0.0, 1.0)
	target.global_transform = gt_prev.interpolate_with(gt_current, f)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		call_deferred("update_transform")
	if do_interpolate:
		call_deferred("interpolate_transform")
		


func _physics_process(_delta):
	if Engine.is_editor_hint():
		update_editor_transform()
		return
	
	if not target:
		target = get_node_or_null(remote_target)
		if target:
			target.top_level = true
			target.global_transform = global_transform
			gt_prev = target.global_transform
			gt_current = global_transform
		return
		
	if smoothing:
		if not global_transform.is_equal_approx(target.global_transform):
			update = true
			do_interpolate = true
		else:
			do_interpolate = false
	else:
		
		target.global_transform = global_transform

func update_editor_transform():
	target = get_node_or_null(remote_target)
	if not target:
		print("remote transform target is null")
		return
	target.global_transform = global_transform
