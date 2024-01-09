@tool
class_name  BPBRagdoll
extends Node3D

@export var ragdoll_active : bool = true :
	set(value):
		ragdoll_active = value
		_ragdoll_active(value)

@export var make_ragdoll : bool = false :
	set(value):
		make_ragdoll = false
		_make_ragdoll()
		
@export var collide_with_player : bool = true

@export var save_pose_up : bool = false :
	set(value):
		save_pose_up = false
		_save_pose_up()
		
@export var res_pose_up : Res_BPBRagdoll

@export var save_pose_down : bool = false :
	set(value):
		save_pose_down = false
		_save_pose_down()
		
@export var res_pose_down : Res_BPBRagdoll

@export var skeleton_path : NodePath
@export var head_radius : float = 0.3
@export var body_radius : float = 0.05
@export var arm_radius : float = 0.1
@export var leg_radius : float = 0.1
@export var body_height : float = 0.3
@export var hand_height : float = 0.1
@export var foot_height : float = 0.1

var skeleton : Skeleton3D
var bone_lists : Array = ["Hips", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Spine", "Chest", "UpperChest", "Head", "HeadTop", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftToes", "RightToes"]
var ragdoll_bone_lists : Array = ["Hips", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Spine", "Chest", "UpperChest", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "RightUpperLeg", "RightLowerLeg", "RightFoot"]
var ragdoll_bones_for_impulse : Array = ["Hips", "Spine", "Chest", "UpperChest"]
var bone_index = {}
var bone_transform = {}
var rigidbodies = {}
var bone_ragdoll_transform = {}
var physic_bone_pair = {}
var default_transforms = {}

var physical_bones = {}
var ragdoll_rids = []
var helper = {}

func _make_ragdoll():
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	get_bone_name()
	get_bone_transform()
	for obj in find_children("*", "RigidBody3D"):
		obj.queue_free()
	for obj in find_children("*", "Generic6DOFJoint3D"):
		obj.queue_free()
	#for obj in find_children("*", "Marker3D"):
	#	obj.queue_free()
	await get_tree().create_timer(0.1).timeout
	
	make_rigidbodies("Hips", "Spine", body_radius, body_height, true)
	make_rigidbodies("Spine", "Chest", body_radius, body_height, true)
	make_rigidbodies("Chest", "UpperChest", body_radius, body_height, true)
	make_rigidbodies("UpperChest", "Head", body_radius, body_height, true)
	make_rigidbodies("Head", "HeadTop", head_radius, body_height, false, true)
	
	make_rigidbodies("LeftUpperArm", "LeftLowerArm", arm_radius, 0.5, true, true)
	make_rigidbodies("LeftLowerArm", "LeftHand", arm_radius, 0.5, true, true)
	make_rigidbodies("RightUpperArm", "RightLowerArm", arm_radius, 0.5, true, true)
	make_rigidbodies("RightLowerArm", "RightHand", arm_radius, 0.5, true, true)
	
	make_rigidbodies("LeftUpperLeg", "LeftLowerLeg", leg_radius, 0.5, false, true)
	make_rigidbodies("LeftLowerLeg", "LeftFoot", leg_radius, 0.5, false, true)
	make_rigidbodies("RightUpperLeg", "RightLowerLeg", leg_radius, 0.5, false, true)
	make_rigidbodies("RightLowerLeg", "RightFoot", leg_radius, 0.5, false, true)
	
	make_rigidbodies("RightHand", "RightLowerArm", arm_radius, hand_height, true, false)
	make_rigidbodies("LeftHand", "LeftLowerArm", arm_radius, hand_height, true, false)
	make_rigidbodies("RightFoot", "RightToes", leg_radius, foot_height, false, true)
	make_rigidbodies("LeftFoot", "LeftToes", leg_radius, foot_height, false, true)
	fix_edge_bone_position()
	make_joints("Hips", "Spine", 20, -10, 0, 0, 20, 0)
	make_joints("Spine", "Chest", 20, -10, 0, 0, 20, 0)
	make_joints("Chest", "UpperChest", 20, -10, 0, 0, 20, 0)
	make_joints("UpperChest", "Head", 10, -10, 0, 0, 10, 0)
	make_joints("UpperChest", "LeftUpperArm", 0, -80, 20, -20, 90, -30)
	make_joints("LeftUpperArm", "LeftLowerArm", 0, -120, 0, 0, 0, 0)
	make_joints("LeftLowerArm", "LeftHand", 20, -20, 20, -20, 20, -20)
	make_joints("UpperChest", "RightUpperArm", 0, -80, 20, -20, 90, -30)
	make_joints("RightUpperArm", "RightLowerArm", 0, -120, 0, 0, 0, 0)
	make_joints("RightLowerArm", "RightHand", 20, -20, 20, -20, 20, -20)
	make_joints("Hips", "LeftUpperLeg", 30, -90, 45, 0, 0, 0)
	make_joints("LeftUpperLeg", "LeftLowerLeg", 0, -90, 0, 0, 0, 0)
	make_joints("LeftLowerLeg", "LeftFoot", 20, -20, 0, 0, 10, -10)
	make_joints("Hips", "RightUpperLeg", 30, -90, 45, 0, 0, 0)
	make_joints("RightUpperLeg", "RightLowerLeg", 0, -90, 0, 0, 0, 0)
	make_joints("RightLowerLeg", "RightFoot", 20, -20, 0, 0, 10, -10)
	await get_tree().create_timer(0.1).timeout
	make_markers("Hips")
	make_markers("Spine")
	make_markers("Chest")
	make_markers("UpperChest")
	make_markers("Head")
	make_markers("RightUpperArm")
	make_markers("RightLowerArm")
	make_markers("RightHand")
	make_markers("RightUpperLeg")
	make_markers("RightLowerLeg")
	make_markers("RightFoot")
	make_markers("LeftUpperArm")
	make_markers("LeftLowerArm")
	make_markers("LeftHand")
	make_markers("LeftUpperLeg")
	make_markers("LeftLowerLeg")
	make_markers("LeftFoot")
	
func get_bone_name():
	for i in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(i)
		bone_index[bone_name] = i
		
func get_bone_transform():
	for bone_name in bone_lists:
		bone_transform[bone_name] = skeleton.get_bone_global_pose(bone_index[bone_name])

func make_rigidbodies(BoneA, BoneB, radius, height, rotated=false, calculate_height_from_distance=false):
	#hip
	var distance = (bone_transform[BoneB].origin).distance_to(bone_transform[BoneA].origin)
	var hip_pos = bone_transform[BoneA].origin + ((bone_transform[BoneB].origin - bone_transform[BoneA].origin) * 0.5)
	var rb = RigidBody3D.new()
	add_child(rb)
	rb.owner = owner
	rb.position = hip_pos
	var cs : CollisionShape3D = CollisionShape3D.new()
	var shape : CapsuleShape3D = CapsuleShape3D.new()
	cs.shape = shape
	rb.add_child(cs)
	cs.owner = rb.owner
	if rotated:
		cs.rotation_degrees = Vector3(0.0,0.0,90.0)
	shape.radius = radius
	if calculate_height_from_distance:
		shape.height = distance
	else:
		shape.height = height
	rb.name = BoneA
	cs.name = "CS" + BoneA
	rigidbodies[BoneA] = rb
	
	rb.set_collision_layer_value(1, false)
	rb.set_collision_layer_value(9, true)
	rb.set_collision_mask_value(1, true)
	if collide_with_player:
		rb.set_collision_mask_value(2, true)
	rb.set_collision_mask_value(3, true)
	rb.set_collision_mask_value(9, true)
	rb.mass = 2.0
	rb.freeze = true
	#rb.top_level = true

func fix_edge_bone_position():
	var lower_arm_height = get_node("RightLowerArm/CSRightLowerArm").shape.height
	var hand_height = get_node("RightHand/CSRightHand").shape.height
	var foot_height = get_node("RightFoot/CSRightFoot").shape.height
	rigidbodies["RightHand"].position += Vector3.RIGHT * -((lower_arm_height * 0.5) + (hand_height * 0.5))
	rigidbodies["LeftHand"].position += Vector3.RIGHT * ((lower_arm_height * 0.5) + (hand_height * 0.5))
	rigidbodies["RightFoot"].position += Vector3.BACK * (foot_height * 0.5)
	rigidbodies["LeftFoot"].position += Vector3.BACK * (foot_height * 0.5)

func make_joints(boneA, boneB, xupper=0.0, xlower=0.0, yupper=0.0, ylower=0.0, zupper=0.0, zlower=0.0):
	#Hips
	var joint : Generic6DOFJoint3D = Generic6DOFJoint3D.new()
	joint.transform = bone_transform[boneB]
	joint.node_a = "../" + boneA
	joint.node_b = "../" + boneB
	add_child(joint)
	joint.owner = owner
	joint.name = "J" + boneB
	joint.set("angular_limit_x/upper_angle", deg_to_rad(xupper))
	joint.set("angular_limit_x/lower_angle", deg_to_rad(xlower))
	joint.set("angular_limit_y/upper_angle", deg_to_rad(yupper))
	joint.set("angular_limit_y/lower_angle", deg_to_rad(ylower))
	joint.set("angular_limit_z/upper_angle", deg_to_rad(zupper))
	joint.set("angular_limit_z/lower_angle", deg_to_rad(zlower))

func make_markers(bone_name):
	var marker = Marker3D.new()
	var bone = get_node(bone_name)
	bone.add_child(marker)
	marker.owner = bone.owner
	marker.global_transform =  bone_transform[bone_name]
	marker.name = "Transform" + bone_name
	
	
func _ragdoll_active(value):
	set_physics_process(value)
	for rb in find_children("*", "RigidBody3D"):
		rb.freeze = not value
	
	
func get_ragdoll_bone():
	for marker in find_children("*", "Marker3D"):
		var bone_name = marker.get_parent().name
		bone_ragdoll_transform[bone_name] = marker
	
func get_physicbone_pair():
	for obj in skeleton.find_children("*", "PhysicalBone3D"):
		for bone_name in bone_ragdoll_transform.keys():
			if obj.bone_name == bone_name:
				physic_bone_pair[bone_name] = obj

func save_default_transforms():
	default_transforms["myself"] = transform
	for obj in find_children("*", "RigidBody3D"):
		default_transforms[obj] = obj.transform
	for obj in find_children("*", "CollisionShape3D"):
		default_transforms[obj] = obj.transform
	for obj in find_children("*", "Marker3D"):
		default_transforms[obj] = obj.transform
	for obj in find_children("*", "Generic6DOFJoint3D"):
		default_transforms[obj] = obj.transform

func reset_default_transform():
	transform = default_transforms["myself"]
	for obj in default_transforms.keys():
		if not obj is String:
			obj.transform = default_transforms[obj]
	
func get_physical_bones():
	for obj in skeleton.find_children("*", "PhysicalBone3D"):
		physical_bones[obj.bone_name] = obj
		
func _ready():
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	save_default_transforms()
	get_bone_name()
	get_ragdoll_bone()
	get_physicbone_pair()
	collect_ragdoll_rids()
	get_physical_bones()
	
func collect_ragdoll_rids():
	for obj in find_children("*", "RigidBody3D"):
		ragdoll_rids.append(obj.get_rid())
	
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	if not skeleton:
		skeleton = get_node_or_null(skeleton_path)
		return
		
	if not ragdoll_active:
		return
		
	for bone_name in ragdoll_bone_lists:
		var bindex = bone_index[bone_name]
		var marker = bone_ragdoll_transform[bone_name]
		var btransform = marker.global_transform
		skeleton.set_bone_global_pose_override(bindex, global_transform.inverse() * btransform, 1.0)

		
func start_physical_simulation():
	ragdoll_active = true
	#skeleton.physical_bones_start_simulation()
	for obj in find_children("*", "RigidBody3D"):
		obj.top_level = true
	
func stop_physical_simulation():
	ragdoll_active = false
	#skeleton.physical_bones_stop_simulation()
	for obj in find_children("*", "RigidBody3D"):
		obj.top_level = false
	skeleton.clear_bones_global_pose_override()

	
func apply_impulse(force):
	for bone_name in ragdoll_bone_lists:
		var force_multiplier := randf_range(0.75, 1.0)
		if bone_name in ragdoll_bones_for_impulse:
			force_multiplier = 1.0
		bone_ragdoll_transform[bone_name].get_parent().apply_central_impulse(force * force_multiplier)

func _save_pose_up():
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	if not res_pose_up:
		res_pose_up = Res_BPBRagdoll.new() as Res_BPBRagdoll
	res_pose_up.save_bone_transform(skeleton)
	notify_property_list_changed()

func _save_pose_down():
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	if not res_pose_down:
		res_pose_down = Res_BPBRagdoll.new() as Res_BPBRagdoll
	res_pose_down.save_bone_transform(skeleton)
	notify_property_list_changed()
	
func get_hips_global_transform():
	return get_node("Hips").global_transform
	#return bone_ragdoll_transform["Hips"].global_transform

func get_spine_global_transform():
	return get_node("Spine").global_transform
	#return bone_ragdoll_transform["Spine"].global_transform
	
func get_res_pose_up():
	return res_pose_up
	
func get_res_pose_down():
	return res_pose_down

func play_get_up(): 
	var res_pose : Res_BPBRagdoll
	var hip_transform = get_hips_global_transform()
	var spine_transform = get_spine_global_transform()
	var face_up = true
	var bas_x = Vector3.RIGHT
	var bas_y = Vector3.UP
	var bas_z = (spine_transform.origin - hip_transform.origin).slide(bas_y).normalized()
	
	if hip_transform.basis.z.dot(Vector3.UP) > 0.0:
		face_up = true
		res_pose = get_res_pose_up()
		bas_z *= -1
	else:
		face_up = false
		res_pose = get_res_pose_down()
		
	bas_x = bas_y.cross(bas_z)

	transform.basis = Basis(bas_x, bas_y, bas_z)
	
	for bone_name in ragdoll_bone_lists:
		var tween = create_tween()
		#var target_transform = global_transform.inverse() * res_pose.get_bone_transform(bone_name) 
		var target_transform = make_helper(bone_name, res_pose)
		#tween.tween_property(bone_ragdoll_transform[bone_name], "global_transform", target_transform, 1.0)
		var obj = bone_ragdoll_transform[bone_name]
		tween.tween_method(slerp_transform.bind(obj.global_transform.orthonormalized(), target_transform.orthonormalized(), obj), 0.0, 1.0, 1.0)

	await get_tree().create_timer(2.0).timeout
	stop_physical_simulation()
	reset_default_transform()
	### TODO : MOVE PLAYER BODY TO CORRECT TRANSFORM FIRST BEFORE PLAYING ANIMATION
	
	var anim = owner.find_children("*", "AnimationPlayer").front()
	if face_up:
		anim.play("FALL_BACK")
	else:
		anim.play("FALL_FWD")
	anim.seek(2.0)
	
	
func make_helper(bone_name, res_pose):
	if not helper.has(bone_name):
		var marker = Marker3D.new()
		add_child(marker)
		marker.owner = owner
		helper[bone_name] = marker
	helper[bone_name].transform = res_pose.get_bone_transform(bone_name)
	
	return helper[bone_name].global_transform

func get_ragdoll_rid():
	return ragdoll_rids

func slerp_transform(weight:float, old_transform:Transform3D, new_transform:Transform3D, object):
	
	var old_pos = old_transform.origin 
	var new_pos = new_transform.origin
	
	var old_bas = old_transform.basis
	var new_bas = new_transform.basis
	
	var lerp_origin = old_pos.slerp(new_pos, weight)
	var lerp_basis = old_bas.slerp(new_bas, weight)
	var lerp_transform = Transform3D(lerp_basis, lerp_origin)
	object.global_transform = lerp_transform
	#return lerp_transform
