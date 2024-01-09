@tool
class_name Res_BPBRagdoll
extends Resource

@export var bone_transforms : Dictionary = {}

var ragdoll_bone_lists : Array = ["Hips", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Spine", "Chest", "UpperChest", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "RightUpperLeg", "RightLowerLeg", "RightFoot"]
var bone_index : Dictionary = {}

func _get_property_list():
	var _properties = []
	_properties.append(
	{
		"name":"bone_transforms",
		"type":TYPE_DICTIONARY,
		"usage":PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_NO_EDITOR,
	})
	return _properties

func save_bone_transform(skeleton : Skeleton3D):
	var bone_lists = ["hips", "leftupperleg", "leftlowerleg", "leftfoot", "spine", "chest", "upperchest", "head", "leftupperarm", "leftlowerarm", "lefthand", "rightupperarm", "rightlowerarm", "righthand", "rightupperleg", "rightlowerleg", "rightfoot"]
	get_bone_name(skeleton)
	for bone_name in bone_index.keys():
		if bone_name in ragdoll_bone_lists:
			bone_transforms[bone_name] = skeleton.get_bone_global_pose(bone_index[bone_name])
			
	#var phybones = skeleton.find_children("*", "BoneAttachment3D")
	#for b in phybones:
	#	var bone_name = b.name # b.name.substr(2,-1)
	#	bone_transforms[bone_name] = b.transform
		
	#for i in skeleton.get_bone_count():
		#bone_idx[skeleton.get_bone_name(i)] = i
	#	var bone_name = skeleton.get_bone_name(i)
	#	if bone_name.to_lower() in bone_lists:
	#		bone_transforms[skeleton.get_bone_name(i)] = skeleton.get_bone_global_pose(i)
	#		print(skeleton.get_bone_name(i), " transform = ", skeleton.get_bone_global_pose(i))

func get_bone_name(skeleton : Skeleton3D):
	for i in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(i)
		bone_index[bone_name] = i
		
func get_bone_transform(bone_name):
	return bone_transforms.get(bone_name)

