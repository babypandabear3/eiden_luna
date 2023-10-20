@tool
extends EditorPlugin

enum _MODE {
	NORMAL,
	PLACEMENT,
	ROTATE,
	SCALE,
	GSR_GRAB,
	GSR_ROTATE,
}

enum _AXIS {
	X,
	Y,
	Z,
	SNAP,
	PLANE_XY,
	PLANE_XZ,
	PLANE_YZ,
}

var root_normal_ui
var root_normal_ui_is_active := false

var editor_interface : EditorInterface
var editor_selection : EditorSelection

var active_editor
var active_root
var placement_options : Dictionary

var ghost_path = ""
var ghost = null
var ghost_basis_init : Basis
var ghost_last_scale : float = 1.0

@onready var mode : _MODE = _MODE.NORMAL
@onready var axis : _AXIS = _AXIS.Y

var ghost_initial_transform : Transform3D
var event_last_position : Vector2 = Vector2.ZERO

var rotation_x := 0.0 
var rotation_y := 0.0
var rotation_z := 0.0
var rotation_speed := 0.01

var stop_input_passthrough = false

var gsr_objects = {}
var gsr_snap = false
var gsr_snap_grab := Vector3.ONE * 0.5
var gsr_pivot : Transform3D
var gsr_rotation_pivot : Vector3
var gsr_rotation_offsets = {}
var gsr_rotation_original_transform = {}
var gsr_obj_col_rid := []

var placement_rotation_init = Vector3.ZERO
var gsr_rotation : float
var prev_axis = _AXIS.Y
@onready var gsr_snap_rotation = deg_to_rad(15.0)
var undo_redo : EditorUndoRedoManager

func _enter_tree():
	pass
	undo_redo = get_undo_redo()
	add_custom_type("RootBasic", "Node3D", preload("root_node/root_basic.gd"), preload("res://addons/bpb_placement/icon/circleG.png"))
	root_normal_ui = load("res://addons/bpb_placement/ui/root_normal_ui.tscn").instantiate()
	editor_interface = get_editor_interface()
	editor_selection = get_editor_interface().get_selection()
	editor_selection.selection_changed.connect(Callable(self, "selection_change"))
	root_normal_ui.editor_interface = editor_interface
	
func _exit_tree():
	pass
	active_root = false
	if root_normal_ui_is_active:
		remove_control_from_bottom_panel(root_normal_ui)
		root_normal_ui_is_active = false
		active_editor = null
				
	if ghost:
		ghost.free()
		
	remove_custom_type("MyButton")
	root_normal_ui.queue_free()

	
func selection_change():
	var selected_objects = editor_selection.get_selected_nodes()
	if selected_objects.size() == 1:
		var selected = selected_objects[0]
		if selected is BPB_Root_Basic:
			if not root_normal_ui_is_active:
				add_control_to_bottom_panel(root_normal_ui, "Placement")
				root_normal_ui_is_active = true
				active_editor = root_normal_ui
				active_root = selected
		else:
			active_root = false
			if root_normal_ui_is_active:
				remove_control_from_bottom_panel(root_normal_ui)
				root_normal_ui_is_active = false
				active_editor = null
				

func _handles(object):
	if object is BPB_Root_Basic:
		return true
	elif object is Node3D:
		return true
		
	return object == null
	
func _forward_3d_gui_input(viewport_camera, event):
	if active_editor:
		placement_options = active_editor.get_placement_options()
	else:
		placement_options = {}
		
	match mode:
		_MODE.NORMAL:
			do_normal(viewport_camera, event)
			if event is InputEventKey and event.pressed:
				if event.keycode == KEY_G:
					start_gsr_grab(viewport_camera)
				if event.keycode == KEY_R:
					start_gsr_rotate(viewport_camera)
					
			if event is InputEventKey:
				if event.keycode == KEY_SPACE and event.alt_pressed and event.pressed:
					root_normal_ui.toggle_placement()
					stop_input_passthrough = true
		_MODE.PLACEMENT:
			do_placement(viewport_camera, event)
			if event is InputEventKey:
				if event.keycode == KEY_SPACE and event.alt_pressed and event.pressed:
					root_normal_ui.toggle_placement()
					stop_input_passthrough = true
		_MODE.ROTATE:
			do_rotate(viewport_camera, event)
		_MODE.SCALE:
			do_scale(viewport_camera, event)
		_MODE.GSR_GRAB:
			do_gsr_grab(viewport_camera, event)
		_MODE.GSR_ROTATE:
			do_gsr_rotate(viewport_camera, event)
			
	if stop_input_passthrough:
		stop_input_passthrough = false
		return true


func do_normal(viewport_camera, event):
	if active_editor:
		active_editor.set_mode_text("NORMAL")
		
	if weakref(ghost).get_ref():
		ghost.hide()
		
	if placement_options.is_empty():
		return false
	
	if placement_options.placement_active:
		start_placement()
		
		
func start_placement():
	prev_axis = _AXIS.SNAP
	axis = _AXIS.SNAP
	mode = _MODE.PLACEMENT
	
func do_placement(viewport_camera, event):
	if active_editor:
		active_editor.set_mode_text("PLACEMENT")
		
	var is_placement_active = placement_options.get("placement_active")
	if not is_placement_active:
		mode = _MODE.NORMAL
	
	if placement_options.last_selected_path == "":
		return false
		
	if placement_options.last_selected_path != ghost_path:
		create_ghost(placement_options.last_selected_path)
	ghost.show()
	
	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			if event.is_pressed():
				gsr_snap = true
			if event.is_released():
				gsr_snap = false
				
		if event.is_pressed():
			if event.keycode == KEY_X:
				if event.shift_pressed:
					axis = _AXIS.PLANE_YZ
					gsr_pivot = ghost.global_transform
				else:
					if axis == _AXIS.X:
						axis = _AXIS.SNAP
					else:
						axis = _AXIS.X
						gsr_pivot = ghost.global_transform
			if event.keycode == KEY_Y:
				if event.shift_pressed:
					axis = _AXIS.PLANE_XZ
					gsr_pivot = ghost.global_transform
				else:
					if axis == _AXIS.Y:
						axis = _AXIS.SNAP
					else:
						axis = _AXIS.Y
						gsr_pivot = ghost.global_transform
			if event.keycode == KEY_Z:
				if event.shift_pressed:
					axis = _AXIS.PLANE_XY
					gsr_pivot = ghost.global_transform
				else:
					if not event.ctrl_pressed:
						if axis == _AXIS.Z:
							axis = _AXIS.SNAP
						else:
							axis = _AXIS.Z
							gsr_pivot = ghost.global_transform
			if event.keycode == KEY_S:
				axis = _AXIS.SNAP
				
	if event is InputEventMouseMotion:
		match axis:
			_AXIS.SNAP:
				event_last_position = get_viewport().get_mouse_position()
				var ray_result = _intersect_with_colliders(viewport_camera, event.position)
				if ray_result:
					var offset : Vector3 = ray_result.position
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = offset
					if placement_options.align_y:
						var basis = get_ghost_basis_align_y(ray_result) 
						ghost.global_transform.basis = basis

			_AXIS.X:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.project(Vector3.RIGHT)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = gsr_pivot.origin + offset
			_AXIS.Y:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.project(Vector3.UP)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = gsr_pivot.origin + offset
			_AXIS.Z:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.project(Vector3.FORWARD)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = gsr_pivot.origin + offset
			#		
			_AXIS.PLANE_YZ:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin
					var offset = movement.slide(Vector3.RIGHT)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = gsr_pivot.origin + offset
					
			_AXIS.PLANE_XZ:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin
					var offset = movement.slide(Vector3.UP)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = gsr_pivot.origin + offset
					
			_AXIS.PLANE_XY:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin
					var offset = movement.slide(Vector3.FORWARD)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					ghost.global_transform.origin = gsr_pivot.origin + offset
	
			
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_R:
			if event.alt_pressed:
				#reset rotation 
				var scale = ghost.global_transform.basis.x.length()
				var bas = ghost_basis_init
				bas.x *= scale
				bas.y *= scale
				bas.z *= scale
				ghost.global_transform.basis = bas
			else:
				#enter rotation mode
				ghost_initial_transform = ghost.global_transform
				prev_axis = axis
				axis = _AXIS.Y
				mode = _MODE.ROTATE
				placement_rotation_init = ghost.rotation
				rotation_x = 0.0 
				rotation_y = 0.0
				rotation_z = 0.0
		#if event.keycode == KEY_S:
		#	if event.alt_pressed:
		#		#reset scale
		#		var bas = ghost.global_transform.basis
		#		bas.x = bas.x.normalized()
		#		bas.y = bas.y.normalized()
		#		bas.z = bas.z.normalized()
		#		ghost.global_transform.basis = bas
		#	else:
		#		#enter scale mode
		#		prev_axis = axis
		#		ghost_initial_transform = ghost.global_transform
		#		ghost_last_scale = ghost.global_transform.basis.x.length()
		#		if (get_viewport().get_visible_rect().size.x / 2) > event_last_position.x:
		#			get_viewport().warp_mouse(event_last_position + Vector2(100.0, 0))
		#		else:
		#			get_viewport().warp_mouse(event_last_position + Vector2(-100.0, 0))
		#		mode = _MODE.SCALE
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_object(ghost, placement_options)
			stop_input_passthrough = true
			
func do_rotate(viewport_camera, event):
	if active_editor:
		active_editor.set_mode_text("ROTATION")
				
	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			if event.is_pressed():
				gsr_snap = true
			if event.is_released():
				gsr_snap = false
				
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_R:
			mode = _MODE.PLACEMENT
		if event.keycode == KEY_S and not event.ctrl_pressed:
			mode = _MODE.PLACEMENT
		#if event.keycode == KEY_S:
		#	ghost_last_scale = ghost.global_transform.basis.x.length()
		#	if (get_viewport().get_visible_rect().size.x / 2) > event_last_position.x:
		#		get_viewport().warp_mouse(event_last_position + Vector2(100.0, 0))
		#	else:
		#		get_viewport().warp_mouse(event_last_position + Vector2(-100.0, 0))
		#	mode = _MODE.SCALE
			
		if event.keycode == KEY_X:
			axis = _AXIS.X
		if event.keycode == KEY_Y:
			axis = _AXIS.Y
		if event.keycode == KEY_Z:
			if not event.ctrl_pressed:
				axis = _AXIS.Z
			
	elif event is InputEventMouseMotion:
		if axis == _AXIS.X:
			rotation_x += event.relative.x * rotation_speed
			var applied_rot = rotation_x
			if gsr_snap:
				applied_rot = deg_to_rad( snappedf(rad_to_deg(applied_rot), 15.0) )
			ghost.rotation.x = wrapf(placement_rotation_init.x + applied_rot, -PI, PI)
		if axis == _AXIS.Y:
			rotation_y += event.relative.x * rotation_speed
			var applied_rot = rotation_y
			if gsr_snap:
				applied_rot = deg_to_rad( snappedf(rad_to_deg(applied_rot), 15.0) )
			ghost.rotation.y = wrapf(placement_rotation_init.y + applied_rot, -PI, PI)
		if axis == _AXIS.Z:
			rotation_z += event.relative.x * rotation_speed
			var applied_rot = rotation_z
			if gsr_snap:
				applied_rot = deg_to_rad( snappedf(rad_to_deg(applied_rot), 15.0) )
			ghost.rotation.z = wrapf(placement_rotation_init.z + applied_rot, -PI, PI)
			
	elif event is InputEventMouseButton :# and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().warp_mouse(event_last_position)
			mode = _MODE.PLACEMENT
			axis = prev_axis
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			get_viewport().warp_mouse(event_last_position)
			ghost.global_transform.basis = ghost_initial_transform.basis
			mode = _MODE.PLACEMENT
			axis = prev_axis
		stop_input_passthrough = true

func do_scale(viewport_camera, event):
	active_editor.set_mode_text("SCALE")
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_R:
			axis = _AXIS.Y
			mode = _MODE.ROTATE
		elif event.keycode == KEY_S:
			mode = _MODE.PLACEMENT
			
	elif event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_mouse_position()
		var scale = mouse_pos.distance_to(event_last_position) / 100
		var bas = ghost.global_transform.basis
		bas.x = bas.x.normalized() * scale * ghost_last_scale
		bas.y = bas.y.normalized() * scale * ghost_last_scale
		bas.z = bas.z.normalized() * scale * ghost_last_scale
		ghost.global_transform.basis = bas
		
	elif event is InputEventMouseButton :# and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().warp_mouse(event_last_position)
			mode = _MODE.PLACEMENT
			axis = prev_axis
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			get_viewport().warp_mouse(event_last_position)
			ghost.global_transform.basis = ghost_initial_transform.basis
			mode = _MODE.PLACEMENT
			axis = prev_axis
		stop_input_passthrough = true
			
func disable_ghost_collider(node):
	gsr_obj_col_rid = []
	
	var kids = node.find_children("*", "CollisionObject3D")
	for k in kids:
		gsr_obj_col_rid.append(k.get_rid())
		
func create_ghost(path):
	ghost_path = path
	if ghost:
		ghost.free()
	ghost = load(path).instantiate()
	disable_ghost_collider(ghost)
	editor_interface.get_edited_scene_root().add_child(ghost)
	ghost_basis_init = ghost.global_transform.basis
	
func get_ghost_basis_align_y(ray_result):
	var n = ray_result.normal
	var dot_x = Vector3.RIGHT.dot(n)
	var dot_y = Vector3.UP.dot(n)
	var dot_z = Vector3.FORWARD.dot(n)
	var dot_xx = Vector3.LEFT.dot(n)
	var dot_yy = Vector3.DOWN.dot(n)
	var dot_zz = Vector3.BACK.dot(n)
	var dot_used = max(dot_x, dot_y, dot_z, dot_xx, dot_yy, dot_zz)
	
	var bas : Basis = ghost.global_transform.basis
	
	if is_equal_approx(dot_used, dot_x):
		bas.x = Vector3.FORWARD
		bas.y = Vector3.RIGHT
		bas.z = Vector3.UP
	if is_equal_approx(dot_used, dot_y):
		bas.x = Vector3.RIGHT
		bas.y = Vector3.UP
		bas.z = Vector3.FORWARD
	if is_equal_approx(dot_used, dot_z):
		bas.x = Vector3.UP
		bas.y = Vector3.FORWARD
		bas.z = Vector3.RIGHT
	if is_equal_approx(dot_used, dot_xx):
		bas.x = Vector3.FORWARD * -1
		bas.y = Vector3.RIGHT * -1
		bas.z = Vector3.UP * -1
	if is_equal_approx(dot_used, dot_yy):
		bas.x = Vector3.RIGHT * -1
		bas.y = Vector3.UP * -1
		bas.z = Vector3.FORWARD * -1
	if is_equal_approx(dot_used, dot_zz):
		bas.x = Vector3.UP * -1
		bas.y = Vector3.FORWARD * -1
		bas.z = Vector3.RIGHT * -1
	
	bas.y = n
	bas.x = (bas.x.slide(n)).normalized()
	bas.z = bas.x.cross(bas.y).normalized()

	return bas


func _intersect_with_colliders(camera, screen_point):
	var from = camera.project_ray_origin(screen_point)
	var dir = camera.project_ray_normal(screen_point)
	var space_state = editor_interface.get_edited_scene_root().get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(from, from + dir * 4096)
	query.exclude = gsr_obj_col_rid
	var result = space_state.intersect_ray(query)
	if result:
		var res = {}
		res.position = result.position
		res.normal = result.normal
		return res
	return null
	
func _intersect_with_plane(camera, screen_point, plane_origin, plane_normal):
	var grid_plane = Plane(plane_normal, plane_origin)
	var from = camera.project_ray_origin(screen_point)
	var dir = camera.project_ray_normal(screen_point)
	
	var result = grid_plane.intersects_ray(from, dir)
	return result

func place_object(_ghost, _placement_options):
	
	var obj = load(ghost_path).instantiate()
	
	undo_redo = get_undo_redo()
	undo_redo.create_action("placement_add_node")
	undo_redo.add_do_method(self, "execute_placement", obj, _ghost, _placement_options)
	undo_redo.add_undo_method(self, "undo_placement", obj)
	undo_redo.add_do_reference(obj)
	undo_redo.commit_action()
	
func execute_placement(obj, _ghost, _placement_options):
	
	var obj_name = obj.name
	active_root.add_child(obj)
	obj.global_transform = _ghost.global_transform
	obj.owner = editor_interface.get_edited_scene_root()
	obj.name = obj_name
	
	if _placement_options["rand_rotate_x"]:
		obj.rotation.x += randf_range(-PI, PI)
	if _placement_options["rand_rotate_y"]:
		obj.rotation.y += randf_range(-PI, PI)
	if _placement_options["rand_rotate_z"]:
		obj.rotation.z += randf_range(-PI, PI)
		
	if not (is_equal_approx(_placement_options["scale_min"], 1.0) and is_equal_approx(_placement_options["scale_max"], 1.0)):
		var scale = randf_range(_placement_options["scale_min"], _placement_options["scale_max"])
		var bas = obj.global_transform.basis
		bas.x = bas.x.normalized() * scale
		bas.y = bas.y.normalized() * scale
		bas.z = bas.z.normalized() * scale
		obj.global_transform.basis = bas

func undo_placement(obj):
	if weakref(obj).get_ref():
		obj.queue_free()

func start_gsr_grab(camera : Camera3D):
	var count := 0
	gsr_objects = {}
	for o in get_editor_interface().get_selection().get_selected_nodes():
		if o is Node3D and not o is BPB_Root_Basic:
			gsr_pivot = o.global_transform
			gsr_objects[o] = o.global_transform
			count += 1
			
	if count == 0:
		return
	else:
		get_gsr_obj_col_rid()
		var mouse_pos = camera.unproject_position(gsr_pivot.origin)
		camera.get_viewport().warp_mouse(mouse_pos)
		mode = _MODE.GSR_GRAB
		axis = _AXIS.SNAP
	
func do_gsr_grab(viewport_camera, event):
	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			if event.is_pressed():
				gsr_snap = true
			if event.is_released():
				gsr_snap = false
				
		if event.is_pressed():
			if event.keycode == KEY_X:
				if event.shift_pressed:
					axis = _AXIS.PLANE_YZ
				else:
					axis = _AXIS.X
			if event.keycode == KEY_Y:
				if event.shift_pressed:
					axis = _AXIS.PLANE_XZ
				else:
					axis = _AXIS.Y
			if event.keycode == KEY_Z:
				if event.shift_pressed:
					axis = _AXIS.PLANE_XY
				else:
					axis = _AXIS.Z
			if event.keycode == KEY_S:
				axis = _AXIS.SNAP
				
	if event is InputEventMouseMotion:
		match axis:
			_AXIS.SNAP:
				var ray_result = _intersect_with_colliders(viewport_camera, event.position)
				if ray_result:
					var offset : Vector3 = ray_result.position - gsr_pivot.origin 
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
			_AXIS.X:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.project(Vector3.RIGHT)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
			_AXIS.Y:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.project(Vector3.UP)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
			_AXIS.Z:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.project(Vector3.FORWARD)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
			_AXIS.PLANE_YZ:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.slide(Vector3.RIGHT)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
			_AXIS.PLANE_XZ:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.slide(Vector3.UP)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
			_AXIS.PLANE_XY:
				var ray_result = _intersect_with_plane(viewport_camera, event.position, gsr_pivot.origin, viewport_camera.global_transform.basis.z)
				if ray_result:
					var movement : Vector3 = ray_result - gsr_pivot.origin 
					var offset = movement.slide(Vector3.FORWARD)
					if gsr_snap:
						offset = offset.snapped(gsr_snap_grab)
					for node in gsr_objects.keys():
						node.global_transform.origin = gsr_objects[node].origin + offset
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			commit_gsr()
			mode = _MODE.NORMAL
			stop_input_passthrough = true
		if event.button_index == MOUSE_BUTTON_RIGHT:
			mode = _MODE.NORMAL
			for node in gsr_objects.keys():
				node.global_transform = gsr_objects[node]
			stop_input_passthrough = true
	
func start_gsr_rotate(camera):
	var count := 0
	gsr_objects = {}
	gsr_rotation_pivot = Vector3.ZERO
	for o in get_editor_interface().get_selection().get_selected_nodes():
		if o is Node3D and not o is BPB_Root_Basic:
			gsr_pivot = o.global_transform
			gsr_objects[o] = o.global_transform
			count += 1
			gsr_rotation_pivot += o.global_transform.origin
	if count == 0:
		return
	else:
		get_gsr_obj_col_rid()
		gsr_rotation_pivot /= count
		mode = _MODE.GSR_ROTATE
		axis = _AXIS.Y
		gsr_rotation = 0.0
		gsr_rotation_offsets = {}
		for o in gsr_objects.keys():
			var offset = gsr_objects[o].origin - gsr_rotation_pivot
			gsr_rotation_offsets[o] = offset
			gsr_rotation_original_transform[o] = o.global_transform
	
func do_gsr_rotate(viewport_camera, event):
	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			if event.is_pressed():
				gsr_snap = true
			if event.is_released():
				gsr_snap = false
				
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_X:
			axis = _AXIS.X
		if event.keycode == KEY_Y:
			axis = _AXIS.Y
		if event.keycode == KEY_Z:
			axis = _AXIS.Z
			
	elif event is InputEventMouseMotion:
		if axis == _AXIS.X:
			for gsr_object in gsr_objects.keys():
				var gsr_rotation_angle = event.relative.x * rotation_speed
				gsr_rotation += gsr_rotation_angle
				var rotation = gsr_rotation
				if gsr_snap:
					rotation = snappedf(rotation, gsr_snap_rotation)
				var offset = gsr_rotation_offsets[gsr_object].rotated(Vector3.RIGHT, rotation)
				gsr_object.global_position = gsr_rotation_pivot + offset
				var bas = gsr_rotation_original_transform[gsr_object].basis
				bas = bas.rotated(Vector3.RIGHT, rotation)
				gsr_object.global_transform.basis = bas
		if axis == _AXIS.Y:
			for gsr_object in gsr_objects.keys():
				var gsr_rotation_angle = event.relative.x * rotation_speed
				gsr_rotation += gsr_rotation_angle
				var rotation = gsr_rotation
				if gsr_snap:
					rotation = snappedf(rotation, gsr_snap_rotation)
				var offset = gsr_rotation_offsets[gsr_object].rotated(Vector3.UP, rotation)
				gsr_object.global_position = gsr_rotation_pivot + offset
				var bas = gsr_rotation_original_transform[gsr_object].basis
				bas = bas.rotated(Vector3.UP, rotation)
				gsr_object.global_transform.basis = bas
		if axis == _AXIS.Z:
			for gsr_object in gsr_objects.keys():
				var gsr_rotation_angle = event.relative.x * rotation_speed
				gsr_rotation += gsr_rotation_angle
				var rotation = gsr_rotation
				if gsr_snap:
					rotation = snappedf(rotation, gsr_snap_rotation)
				var offset = gsr_rotation_offsets[gsr_object].rotated(Vector3.FORWARD, rotation)
				gsr_object.global_position = gsr_rotation_pivot + offset
				var bas = gsr_rotation_original_transform[gsr_object].basis
				bas = bas.rotated(Vector3.FORWARD, rotation)
				gsr_object.global_transform.basis = bas
			
	elif event is InputEventMouseButton :# and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			commit_gsr()
			mode = _MODE.NORMAL
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			for node in gsr_objects.keys():
				node.global_transform = gsr_objects[node]
			mode = _MODE.NORMAL
		stop_input_passthrough = true

func get_gsr_obj_col_rid():
	gsr_obj_col_rid = []
	for node in gsr_objects.keys():
		var kids = node.find_children("*", "CollisionObject3D")
		for k in kids:
			gsr_obj_col_rid.append(k.get_rid())
	
	
func commit_gsr():
	undo_redo.create_action("update_transform")
	var new_transforms = {}
	for node in gsr_objects.keys():
		new_transforms[node] = node.global_transform
	undo_redo.add_do_method(self, "execute_gsr", gsr_objects, new_transforms)
	undo_redo.add_undo_method(self, "undo_gsr", gsr_objects)
	undo_redo.add_do_reference(gsr_objects.keys().front())
	undo_redo.commit_action()
	
func execute_gsr(objs, new_transform):
	for node in objs.keys():
		node.global_transform = new_transform[node]
		
	
func undo_gsr(objs):
	for node in objs.keys():
		node.global_transform = objs[node]
