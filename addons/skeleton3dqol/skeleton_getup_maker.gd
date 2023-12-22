@tool
class_name Skeleton_Getup_Maker
extends Node3D
		
@export var skeleton_path : NodePath
@export var animation_player_path : NodePath
@export var record_face_up : bool = false:
	set(value):
		_record_face_up()
		record_face_up = false
		
@export var record_face_down : bool = false:
	set(value):
		_record_face_down()
		record_face_down = false

@export var face_up : Res_Get_up
@export var face_down : Res_Get_up

@export var tween_time : float = 0.5

var skeleton : Skeleton3D
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _record_face_up():
	skeleton = get_node_or_null(skeleton_path)
	if not skeleton:
		print("Skeleton not found")
		return
	
	create_marker()
	await get_tree().create_timer(0.1).timeout
	
	if not face_up:
		face_up = Res_Get_up.new()
	face_up.save_bone_transform(skeleton)
	
	remove_marker()
	
	
	#make_lerp_target(face_up)
	

		
func _record_face_down():
	skeleton = get_node_or_null(skeleton_path)
	if not skeleton:
		print("Skeleton not found")
		return
		
	create_marker()
	await get_tree().create_timer(0.1).timeout
	
	if not face_down:
		face_down = Res_Get_up.new()
	face_down.save_bone_transform(skeleton)
	
	remove_marker()
	
	notify_property_list_changed()
	#make_lerp_target(face_down)
	
func make_lerp_target(res):
	for o in get_children():
		o.free()
	for bone_name in res.bone_transforms.keys():
		var marker = Marker3D.new()
		add_child(marker)
		marker.owner = owner
		marker.transform = res.bone_transforms[bone_name]
		marker.name = bone_name
	
func tween_physic_bone_to_pose():
	
	skeleton = get_node_or_null(skeleton_path)
	if not skeleton:
		return
		
	var bone_lists = ["hips", "leftupperleg", "leftlowerleg", "leftfoot", "spine", "chest", "upperchest", "head", "leftupperarm", "leftlowerarm", "lefthand", "rightupperarm", "rightlowerarm", "righthand", "rightupperleg", "rightlowerleg", "rightfoot"]
	var bones = skeleton.find_children("*", "PhysicalBone3D")
	
	var exclude_RID = []
	for b in bones:
		exclude_RID.append(b.get_rid())
	
	var hip_transform : Transform3D
	var spine_transform : Transform3D
	for b in bones:
		var bone_name = b.name.substr(2,-1).to_lower()
		if "hips" in bone_name:
			hip_transform = b.global_transform
		if "spine" in bone_name:
			spine_transform = b.global_transform
			
	var facing_up := true
	var res_to_use : Res_Get_up
	if hip_transform.basis.z.dot(Vector3.UP) > 0:
		res_to_use = face_up
	else:
		res_to_use = face_down
		facing_up = false
		
	
	var new_position := hip_transform.origin
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(new_position, new_position + Vector3.DOWN * 10)
	query.exclude = exclude_RID
	var result = space_state.intersect_ray(query)
	if result:
		new_position = result.position

	var spine_position = spine_transform.origin
	var z 
	if facing_up:
		z = (spine_transform.origin.direction_to(hip_transform.origin)).slide(Vector3.UP).normalized()
	else:
		z = (hip_transform.origin.direction_to(spine_transform.origin)).slide(Vector3.UP).normalized()
	var y = Vector3.UP
	var x = y.cross(z)
	var owner_transform = skeleton.owner.global_transform
	owner_transform.basis = Basis(x, y, z)
	owner_transform.origin = new_position
	#skeleton.owner.global_transform = owner_transform
	
	#make marker
	var marker_parent = Marker3D.new()
	add_child(marker_parent)
	marker_parent.name = "marker_parent"
	marker_parent.global_transform = owner_transform
	for bone_name in res_to_use.bone_transforms.keys():
		var marker = Marker3D.new()
		marker_parent.add_child(marker)
		marker.name = bone_name
		marker.transform = res_to_use.bone_transforms[bone_name]
	
	marker_parent.global_position = new_position
	#await get_tree().create_timer(0.1).timeout
	await get_tree().physics_frame
	
	for b in bones:
		var bone_name = b.name.substr(2,-1).to_lower()
		if bone_name in bone_lists:
			var tween : Tween = create_tween()
			var transform_target = get_node("marker_parent/" + bone_name).global_transform #res_to_use.get_bone_transform(bone_name.to_lower()) #get_node(bone_name).global_transform
			tween.tween_property(b, "global_transform", transform_target, tween_time)
	
	await get_tree().create_timer(tween_time).timeout
	
	skeleton.physical_bones_stop_simulation()
	skeleton.owner.hide()
	skeleton.owner.global_transform = owner_transform
	await get_tree().physics_frame
	skeleton.owner.show()
	marker_parent.queue_free()
	
	var anim : AnimationPlayer = get_node_or_null(animation_player_path)
	if not anim:
		print("no animation player")
		return
	if facing_up:
		anim.play("FALL_BACK")
	else:
		anim.play("FALL_FWD")
	anim.seek(2.0)

func create_marker():
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	var bone_lists = ["hips", "leftupperleg", "leftlowerleg", "leftfoot", "spine", "chest", "upperchest", "head", "leftupperarm", "leftlowerarm", "lefthand", "rightupperarm", "rightlowerarm", "righthand", "rightupperleg", "rightlowerleg", "rightfoot"]
	var bone_index = {}
	for i in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(i).to_lower()
		bone_index[bone_name] = i
		if bone_name in bone_lists:
			var ba = BoneAttachment3D.new()
			skeleton.add_child(ba)
			ba.name = bone_name
			ba.bone_idx = i
			ba.owner = skeleton.owner
	
func remove_marker():
	await get_tree().create_timer(0.1).timeout
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	for obj in skeleton.find_children("*", "BoneAttachment3D"):
		obj.free()
	notify_property_list_changed()

