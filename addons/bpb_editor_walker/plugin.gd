@tool
extends EditorPlugin

var scene_root
var editor_player

var editor_walker_ui 
var is_enabled = false

var try_find_player = false
var plugin_camera

func _enter_tree():
	editor_walker_ui = load("res://addons/bpb_editor_walker/ui/editor_walker_ui.tscn").instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_walker_ui)
	editor_walker_ui.plugin_main = self
	
	
func _exit_tree():
	if editor_player:
		editor_player.editor_walker_active = false
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_walker_ui)


func _handles(object):
	return true
	
func _forward_3d_gui_input(viewport_camera, event):
	
	if not is_enabled:
		return
		
	plugin_camera = viewport_camera
	if not editor_player:
		if not can_be_activated():
			return 

	editor_player.plugin_camera = viewport_camera
	
	return true
	
func start_walk():
	is_enabled = true
	get_editor_interface().edit_node(get_editor_interface().get_edited_scene_root())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	editor_player = get_tree().get_first_node_in_group("editor_player")
	if editor_player:
		editor_player.editor_walker_active = true

func end_walk():
	is_enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	editor_player = get_tree().get_first_node_in_group("editor_player")
	if editor_player:
		editor_player.editor_walker_active = false

func can_be_activated():
	try_find_player = false
	find_player(get_editor_interface().get_edited_scene_root())
	if try_find_player:
		return true
	else:
		return false
		
func find_player(node):
	if node is Editor_Player:
		editor_player = node
		editor_player.plugin_camera = plugin_camera
		try_find_player = true
	if try_find_player:
		return
	for o in node.get_children():
		find_player(o)
