@tool
extends EditorPlugin

const menu_i = "res://addons/skeleton3dqol/ui/viewport_menu.tscn"
var menu : Control

var selected_object 
var object_type :String = ""

func _enter_tree():
	menu = load(menu_i).instantiate()
	add_control_to_bottom_panel(menu, "Ragdoll")
	#add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, menu)
	menu._plugin = self
	
	

func _exit_tree():
	remove_control_from_bottom_panel(menu)
	#remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, menu)
	# Clean-up of the plugin goes here.
	pass

func _handles(object):
	if object is Skeleton3D:
		menu.allowed_action(true)
		selected_object = object
		menu.selected_object = object
		object_type = "Skeleton3D"
		return true
	else:
		object_type = ""
		selected_object = null
		menu.allowed_action(false)
		return false

#func create_humanoid_ragdoll():
#	var skeleton = selected_object as Skeleton3D
#	for i in skeleton.get_bone_count():
#		var bone_name = skeleton.get_bone_name(i)
#		var bone_key = bone_name.to_lower()
#		if bc.has(bone_key):
#			var bone_transform = skeleton.get_bone_pose(i)
#			var bone = PhysicalBone3D.new()
#			skeleton.add_child(bone)
#			bone.transform = bone_transform
#			bone.bone_name = bone_name
#			bone.owner = skeleton.owner
#			bone.name = "PB" + bone_name
#			bone.joint_type = PhysicalBone3D.JOINT_TYPE_6DOF
#	pass
