@tool
extends HBoxContainer

var _plugin : EditorPlugin
var selected_object

var bone_id = {}
var bone_transform = {}
var bone_lists = []

var colshape_position_offset_y = {}
var colshape_position_radius_offset_y = {}
var colshape_rotation = {}
var colshape_heights = {}
var colshape_radius = {}

var angular_limit_x = {}
var angular_limit_y = {}
var angular_limit_z = {}

var btn_humanoid_ragdoll
var btn_hide_ragdoll
var btn_show_ragdoll
var sb_head_radius
var sb_arm_radius
var sb_leg_radius
var sb_hand_height
var sb_foot_height
var sb_elbow_upper
var sb_elbow_lower
var sb_knee_upper
var sb_knee_lower
# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_nodes()
	bone_lists = ["hips", "leftupperleg", "leftlowerleg", "leftfoot", "spine", "chest", "upperchest", "head", "leftupperarm", "leftlowerarm", "lefthand", "rightupperarm", "rightlowerarm", "righthand", "rightupperleg", "rightlowerleg", "rightfoot"]
	
	colshape_position_offset_y["head"] = 0.5
	colshape_position_offset_y["leftupperleg"] = 0.5
	colshape_position_offset_y["leftlowerleg"] = 0.5
	colshape_position_offset_y["leftfoot"] = 0.5
	colshape_position_offset_y["rightupperleg"] = 0.5
	colshape_position_offset_y["rightlowerleg"] = 0.5
	colshape_position_offset_y["rightfoot"] = 0.5
	colshape_position_offset_y["leftupperarm"] = 0.5
	colshape_position_offset_y["leftlowerarm"] = 0.5
	colshape_position_offset_y["lefthand"] = 0.5
	colshape_position_offset_y["rightupperarm"] = 0.5
	colshape_position_offset_y["rightlowerarm"] = 0.5
	colshape_position_offset_y["righthand"] = 0.5
	colshape_position_radius_offset_y["hips"] = 1.0
	colshape_position_radius_offset_y["spine"] = 1.0
	colshape_position_radius_offset_y["chest"] = 1.0
	colshape_position_radius_offset_y["upperchest"] = 1.0
	colshape_position_radius_offset_y["head"] = 1.0
	
	colshape_rotation["upperchest"] = Vector3(0.0, 0.0, 90.0)
	colshape_rotation["chest"] = Vector3(0.0, 0.0, 90.0)
	colshape_rotation["spine"] = Vector3(0.0, 0.0, 90.0)
	colshape_rotation["hips"] = Vector3(0.0, 0.0, 90.0)
	colshape_rotation["leftfoot"] = Vector3(37.0, 0.0, 0.0)
	colshape_rotation["rightfoot"] = Vector3(37.0, 0.0, 0.0)
	
	colshape_heights["head"] = 1.0
	colshape_heights["upperchest"] = 0.4
	colshape_heights["chest"] = 0.4
	colshape_heights["spine"] = 0.4
	colshape_heights["hips"] = 0.4
	colshape_heights["leftupperleg"] = 0.36
	colshape_heights["leftlowerleg"] = 0.28
	colshape_heights["leftfoot"] = 0.4
	colshape_heights["rightupperleg"] = 0.36
	colshape_heights["rightlowerleg"] = 0.28
	colshape_heights["rightfoot"] = 0.4
	colshape_heights["leftupperarm"] = 0.44
	colshape_heights["leftlowerarm"] = 0.44
	colshape_heights["lefthand"] = 0.36
	colshape_heights["rightupperarm"] = 0.44
	colshape_heights["rightlowerarm"] = 0.44
	colshape_heights["righthand"] = 0.36
	
	colshape_radius["head"] = 0.5
	colshape_radius["upperchest"] = 0.08
	colshape_radius["chest"] = 0.07
	colshape_radius["spine"] = 0.08
	colshape_radius["hips"] = 0.08
	colshape_radius["leftupperleg"] = 0.12
	colshape_radius["leftlowerleg"] = 0.12
	colshape_radius["leftfoot"] = 0.06
	colshape_radius["rightupperleg"] = 0.12
	colshape_radius["rightlowerleg"] = 0.12
	colshape_radius["rightfoot"] = 0.06
	colshape_radius["leftupperarm"] = 0.1
	colshape_radius["leftlowerarm"] = 0.1
	colshape_radius["lefthand"] = 0.1
	colshape_radius["rightupperarm"] = 0.1
	colshape_radius["rightlowerarm"] = 0.1
	colshape_radius["righthand"] = 0.1
	
func get_nodes():
	btn_humanoid_ragdoll = find_child("btn_humanoid_ragdoll") as Button
	btn_hide_ragdoll = find_child("btn_hide_ragdoll")  as Button
	btn_show_ragdoll = find_child("btn_show_ragdoll") as Button
	sb_head_radius = find_child("sb_head_radius") as SpinBox
	sb_arm_radius = find_child("sb_arm_radius") as SpinBox
	sb_leg_radius = find_child("sb_leg_radius") as SpinBox
	sb_hand_height = find_child("sb_hand_height") as SpinBox
	sb_foot_height = find_child("sb_foot_height") as SpinBox
	sb_elbow_upper = find_child("sb_elbow_upper") as SpinBox
	sb_elbow_lower = find_child("sb_elbow_lower") as SpinBox
	sb_knee_upper = find_child("sb_knee_upper") as SpinBox
	sb_knee_lower = find_child("sb_knee_lower") as SpinBox
	
func allowed_action(_par):
	get_nodes()
	btn_humanoid_ragdoll.disabled = not _par
	btn_hide_ragdoll.disabled  = not _par
	btn_show_ragdoll.disabled = not _par
	
func _on_btn_humanoid_ragdoll_button_up():
	_on_btn_remove_pb_button_up()
	await get_tree().create_timer(0.1).timeout
	create_humanoid_ragdoll()


func create_humanoid_ragdoll():
	var skeleton = selected_object as Skeleton3D
	for i in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(i)
		bone_id[bone_name] = i
		bone_transform[bone_name] = skeleton.get_bone_global_pose(i)
		
	calculate_bone_heights(skeleton)
	make_bones(skeleton)
	
func calculate_bone_heights(skeleton):
	colshape_heights["head"] = (bone_transform["Head"].origin).distance_to(bone_transform["HeadTop"].origin)
	
	colshape_heights["leftupperarm"] = (bone_transform["LeftUpperArm"].origin).distance_to(bone_transform["LeftLowerArm"].origin)
	colshape_heights["leftlowerarm"] = (bone_transform["LeftLowerArm"].origin).distance_to(bone_transform["LeftHand"].origin)
	
	colshape_heights["leftupperleg"] = (bone_transform["LeftUpperLeg"].origin).distance_to(bone_transform["LeftLowerLeg"].origin)
	colshape_heights["leftlowerleg"] = (bone_transform["LeftLowerLeg"].origin).distance_to(bone_transform["LeftFoot"].origin)
	
	colshape_heights["rightupperarm"] = (bone_transform["RightUpperArm"].origin).distance_to(bone_transform["RightLowerArm"].origin)
	colshape_heights["rightlowerarm"] = (bone_transform["RightLowerArm"].origin).distance_to(bone_transform["RightHand"].origin)
	
	colshape_heights["rightupperleg"] = (bone_transform["RightUpperLeg"].origin).distance_to(bone_transform["RightLowerLeg"].origin)
	colshape_heights["rightlowerleg"] = (bone_transform["RightLowerLeg"].origin).distance_to(bone_transform["RightFoot"].origin)
	
	colshape_heights["upperchest"] = (bone_transform["LeftUpperArm"].origin).distance_to(bone_transform["RightUpperArm"].origin)
	colshape_heights["chest"] = colshape_heights["upperchest"]
	colshape_heights["spine"]  =colshape_heights["upperchest"]
	colshape_heights["hips"] = colshape_heights["upperchest"]
	get_nodes()
	colshape_heights["lefthand"] = sb_hand_height.value
	colshape_heights["righthand"] = sb_hand_height.value
	
	colshape_heights["leftfoot"] = sb_foot_height.value
	colshape_heights["rightfoot"] = sb_foot_height.value
	
	colshape_radius["head"] = sb_head_radius.value
	colshape_radius["leftupperarm"] = sb_arm_radius.value
	colshape_radius["leftlowerarm"] = sb_arm_radius.value
	colshape_radius["lefthand"] = sb_arm_radius.value
	colshape_radius["leftupperleg"] = sb_leg_radius.value
	colshape_radius["leftlowerleg"] = sb_leg_radius.value
	colshape_radius["leftfoot"] = sb_leg_radius.value
	
	colshape_radius["rightupperarm"] = sb_arm_radius.value
	colshape_radius["rightlowerarm"] = sb_arm_radius.value
	colshape_radius["righthand"] = sb_arm_radius.value
	colshape_radius["rightupperleg"] = sb_leg_radius.value
	colshape_radius["rightlowerleg"] = sb_leg_radius.value
	colshape_radius["rightfoot"] = sb_leg_radius.value
	
	
	colshape_radius["hips"] = (bone_transform["Hips"].origin).distance_to(bone_transform["Spine"].origin) * 0.5 * 0.8
	colshape_radius["spine"] = (bone_transform["Spine"].origin).distance_to(bone_transform["Chest"].origin) * 0.5 * 0.8
	colshape_radius["chest"] = (bone_transform["Chest"].origin).distance_to(bone_transform["UpperChest"].origin) * 0.5 * 0.8
	colshape_radius["upperchest"] = (bone_transform["UpperChest"].origin).distance_to(bone_transform["Head"].origin) * 0.5 * 0.8
	
func make_bones(skeleton):
	for bone_name in bone_id.keys():
		var bone_key = bone_name.to_lower()
		if bone_lists.has(bone_key):
			var bone = PhysicalBone3D.new()
			bone.set_collision_layer_value(1, false)
			bone.set_collision_layer_value(10, true)
			bone.set_collision_mask_value(1, true)
			bone.set_collision_mask_value(2, true)
			bone.set_collision_mask_value(3, true)
			bone.set_collision_mask_value(10, true)
			skeleton.add_child(bone)
			bone.transform = bone_transform[bone_name]
			bone.bone_name = bone_name
			bone.owner = skeleton.owner
			bone.name = "PB" + bone_name
			bone.joint_type = PhysicalBone3D.JOINT_TYPE_6DOF
			bone.mass = 3.0
			bone.friction = 0.9
			#bone.hide()
			instantiate_colshape(bone, bone_key)
			set_angular_limit(bone, bone_key)
			
			
func instantiate_colshape(bone, bone_key):
	var position_offset_y = 0.0
	var offset_with_height = true
	if colshape_position_offset_y.has(bone_key):
		position_offset_y = colshape_position_offset_y[bone_key]
		
	if colshape_position_radius_offset_y.has(bone_key):
		position_offset_y = colshape_position_radius_offset_y[bone_key]
		offset_with_height = false
		
	var rotation_offset = Vector3.ZERO
	if colshape_rotation.has(bone_key):
		rotation_offset = colshape_rotation[bone_key]
		
	var radius = 0.01
	if colshape_radius.has(bone_key):
		radius = colshape_radius[bone_key]
	
	var height = 0.02
	if colshape_heights.has(bone_key):
		height = colshape_heights[bone_key]
		
	var colshape = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = radius
	shape.height = height
	colshape.shape = shape
	bone.add_child(colshape)
	colshape.owner = bone.owner
	colshape.name = "cs" + bone.name
	if not is_zero_approx( position_offset_y ):
		if offset_with_height:
			colshape.position.y += shape.height * position_offset_y
		else:
			colshape.position.y += shape.radius * position_offset_y
	if not (rotation_offset.is_equal_approx(Vector3.ZERO)):
		colshape.rotation_degrees = rotation_offset


func _on_btn_remove_pb_button_up():
	var all = selected_object.find_children("*", "PhysicalBone3D")
	for obj in all:
		obj.queue_free()
	pass # Replace with function body.

func set_angular_limit(bone, bone_key):
	if "chest" in bone_key:
		set_angular_limit_x(bone, 0.0, -30.0)
	elif "upperleg" in bone_key:
		set_angular_limit_x(bone, 30.0, -30.0)
		set_angular_limit_z(bone, 30.0, -30.0)
	elif "lowerleg" in bone_key:
		set_angular_limit_x(bone, 90.0, 0.0)
	elif "upperarm" in bone_key:
		set_angular_limit_x(bone, 60.0, -60.0)
		set_angular_limit_z(bone, 60.0, -60.0)
	elif "lowerarm" in bone_key:
		set_angular_limit_x(bone, -7.0, -144.0)
		
	set_joint_alternative(bone, bone_key)
	
func set_joint_alternative(bone, bone_key):
	get_nodes()
	bone = bone as PhysicalBone3D
	if "lowerarm" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
		bone.set("joint_rotation", Vector3(0.0, deg_to_rad(-90), 0.0))
		bone.set("joint_constraints/angular_limit_enabled", true)
		bone.set("joint_constraints/angular_limit_upper", sb_elbow_upper.value)
		bone.set("joint_constraints/angular_limit_lower", sb_elbow_lower.value)
	if "lowerleg" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
		bone.set("joint_rotation", Vector3(0.0, deg_to_rad(-90), 0.0))
		bone.set("joint_constraints/angular_limit_enabled", true)
		bone.set("joint_constraints/angular_limit_upper", sb_knee_upper.value)
		bone.set("joint_constraints/angular_limit_lower", sb_knee_lower.value)
	if "upperarm" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_CONE
		bone.set("joint_constraints/swing_span", 89.5)
		bone.set("joint_constraints/twist_span", 10.0)
	if "upperleg" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_CONE
		bone.set("joint_constraints/swing_span", 30.0)
		bone.set("joint_constraints/twist_span", 20.0)
	if "chest" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
		bone.set("joint_rotation", Vector3(0.0, deg_to_rad(-90), 0.0))
		bone.set("joint_constraints/angular_limit_enabled", true)
		bone.set("joint_constraints/angular_limit_upper", 30)
		bone.set("joint_constraints/angular_limit_lower", -30)
	if "spine" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
		bone.set("joint_rotation", Vector3(0.0, deg_to_rad(-90), 0.0))
		bone.set("joint_constraints/angular_limit_enabled", true)
		bone.set("joint_constraints/angular_limit_upper", 30)
		bone.set("joint_constraints/angular_limit_lower", -30)
	if "hips" in bone_key:
		bone.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
		bone.set("joint_rotation", Vector3(0.0, deg_to_rad(-90), 0.0))
		bone.set("joint_constraints/angular_limit_enabled", true)
		bone.set("joint_constraints/angular_limit_upper", 30)
		bone.set("joint_constraints/angular_limit_lower", -30)
	
func set_angular_limit_x(bone, upper=0.0, lower=0.0):
	bone.set("joint_constraints/x/angular_limit_upper", upper)
	bone.set("joint_constraints/x/angular_limit_lower", lower)
	
func set_angular_limit_y(bone, upper=0.0, lower=0.0):
	bone.set("joint_constraints/y/angular_limit_upper", upper)
	bone.set("joint_constraints/y/angular_limit_lower", lower)
	
func set_angular_limit_z(bone, upper=0.0, lower=0.0):
	bone.set("joint_constraints/z/angular_limit_upper", upper)
	bone.set("joint_constraints/z/angular_limit_lower", lower)
	


func _on_btn_hide_ragdoll_button_up():
	for obj in selected_object.find_children("*", "PhysicalBone3D"):
		obj.hide()
	


func _on_btn_show_ragdoll_button_up():
	for obj in selected_object.find_children("*", "PhysicalBone3D"):
		obj.show()

func get_val_as_res():
	get_nodes()
	var res = ResSkeletonGeneric.new()
	res.data["sb_head_radius"] = sb_head_radius.value
	res.data["sb_arm_radius"] = sb_arm_radius.value
	res.data["sb_leg_radius"] = sb_leg_radius.value
	res.data["sb_hand_height"] = sb_hand_height.value
	res.data["sb_foot_height"] = sb_foot_height.value
	res.data["sb_elbow_upper"] = sb_elbow_upper.value
	res.data["sb_elbow_lower"] = sb_elbow_lower.value
	res.data["sb_knee_upper"] = sb_knee_upper.value
	res.data["sb_knee_lower"] = sb_knee_lower.value
	return res
	
func set_res_to_spinboxes(res):
	get_nodes()
	sb_head_radius.value = res.data["sb_head_radius"] 
	sb_arm_radius.value = res.data["sb_arm_radius"] 
	sb_leg_radius.value = res.data["sb_leg_radius"] 
	sb_hand_height.value = res.data["sb_hand_height"] 
	sb_foot_height.value = res.data["sb_foot_height"] 
	sb_elbow_upper.value = res.data["sb_elbow_upper"] 
	sb_elbow_lower.value = res.data["sb_elbow_lower"] 
	sb_knee_upper.value = res.data["sb_knee_upper"] 
	sb_knee_lower.value = res.data["sb_knee_lower"] 
