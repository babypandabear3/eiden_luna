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
var bone_index = {}
var bone_transform = {}
var rigidbodies = {}
var bone_ragdoll_transform = {}
var physic_bone_pair = {}
var default_transforms = {}

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
	for obj in find_children("*", "Marker3D"):
		obj.queue_free()
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
	make_joints("Hips", "Spine", 20, -20, 0, 0, 20, -20)
	make_joints("Spine", "Chest", 20, -20, 0, 0, 20, -20)
	make_joints("Chest", "UpperChest", 20, -20, 0, 0, 20, -20)
	make_joints("UpperChest", "Head", 20, -20, 0, 0, 20, -20)
	make_joints("UpperChest", "LeftUpperArm", 80, -80, 20, -20, 90, -30)
	make_joints("LeftUpperArm", "LeftLowerArm", 0, -120, 0, 0, 0, 0)
	make_joints("LeftLowerArm", "LeftHand", 20, -20, 20, -20, 20, -20)
	make_joints("UpperChest", "RightUpperArm", 80, -80, 20, -20, 90, -30)
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
	rb.set_collision_mask_value(2, true)
	rb.set_collision_mask_value(3, true)
	rb.set_collision_mask_value(9, true)
	
	rb.freeze = true

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
	for obj in find_children("*", "RigidBody3D"):
		default_transforms[obj] = obj.transform
	for obj in find_children("*", "Generic6DOFJoint3D"):
		default_transforms[obj] = obj.transform
	for obj in find_children("*", "Marker3D"):
		default_transforms[obj] = obj.transform

func reset_default_transform():
	for obj in default_transforms.keys():
		obj.transform = default_transforms[obj]
	
func _ready():
	skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if not skeleton:
		return
	save_default_transforms()
	get_bone_name()
	get_ragdoll_bone()
	get_physicbone_pair()
	
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
		skeleton.set_bone_global_pose_override(bindex, btransform, 1.0)
		
func start_physical_simulation():
	ragdoll_active = true
	
func apply_impulse(force):
	for bone_name in bone_ragdoll_transform.keys():
		bone_ragdoll_transform[bone_name].get_parent().apply_central_impulse(force)
