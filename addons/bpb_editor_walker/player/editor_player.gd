@tool
class_name Editor_Player
extends CharacterBody3D

@export var player_path : NodePath
@export var set_player : bool :
	set(value):
		do_set_player(value)
		set_player = false

@export var direction := Vector3.ZERO
@export var SPEED := 5.0
@export var JUMP_VELOCITY := 8.0
@export var gravity_modifier_up := 1.5
@export var gravity_modifier_down := 2.0
@export var coyote_time := 0.1
@export var jump_limit := 2
@export var acc := 15
@export var deacc := 50
@export var impulse_deacc := 55

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var tween_basis : Tween
#var gravity_area_detector = preload("res://system/actor/gravity_area_detector.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_direction := Vector3.DOWN
var airborne := 0.0
var jump_count := 0
var impulse := Vector3.ZERO
var do_jump := false

@export var editor_walker_active := false
var plugin_camera

@onready var axis_y = $camera_root/axis_y
@onready var axis_x = $camera_root/axis_y/axis_x
@onready var gravity_area_detector = $gravity_area_detector
@onready var raycast = $camera_root/axis_y/axis_x

var gravity_areas = []

var camera_sensitivity := 50.0 #THIS SHOULD BE READ FROM GAME SETTING
var camera_multiply = 0.0001
var camera_x_limit_high := 60.0
var camera_x_limit_low := -89.0

var motion = Vector2.ZERO
var input_dir = Vector2.ZERO

var jump_key_pressed = false
var last_major_direction = Vector3.FORWARD

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
		
	gravity_areas.append(Vector3.DOWN)
		
func _physics_process(delta):
	if not editor_walker_active:
		return
	
	#MOUSE LOOK
	var camera_pos = $camera_root/axis_y/axis_x/camera_pos
	motion = Input.get_last_mouse_velocity() * delta
	axis_y.rotate_y(-motion.x * camera_sensitivity * camera_multiply)
	axis_x.rotate_x(-motion.y * camera_sensitivity * camera_multiply)
	axis_x.rotation_degrees.x = clampf(axis_x.rotation_degrees.x, camera_x_limit_low, camera_x_limit_high)
	

	#READ MOVEMENT INPUT
	if Input.is_key_pressed(KEY_SPACE) :
		if not jump_key_pressed:
			jump()
		jump_key_pressed = true
	else:
		jump_key_pressed = false
	
	input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	var dir_x = axis_y.global_transform.basis.x
	var dir_z = axis_y.global_transform.basis.z
	
	var direction = ((dir_x * input_dir.x) + (dir_z * input_dir.y)).normalized()
		
	#MOVEMENT LOGIC
	var vel_h = velocity.slide(gravity_direction)
	var vel_v = velocity.project(gravity_direction)
	if is_on_floor():
		floor_snap_length = 0.3
		airborne = 0.0
		jump_count = 0
		vel_v = gravity_direction
	else:
		var gravity_force = gravity
		if vel_v.normalized().dot(gravity_direction) < 0.0:
			#GOING UP
			gravity_force = gravity * gravity_modifier_up
		else:
			#GOING_DOWN
			gravity_force = gravity * gravity_modifier_down
			
		vel_v += gravity_direction * gravity_force * delta
		floor_snap_length = 0.0
		airborne += delta
		if airborne > coyote_time and jump_count == 0:
			jump_count += 1
		
	if do_jump:
		vel_v = Vector3.ZERO
		vel_v += -gravity_direction * JUMP_VELOCITY
		do_jump = false
		
	if direction.length() > 0.0:
		var motion_h = direction.slide(gravity_direction).normalized() * acc * delta
		vel_h += motion_h
		vel_h = vel_h.limit_length(SPEED)
		last_major_direction = motion_h.normalized()
	else:
		vel_h = lerp(vel_h, Vector3.ZERO, deacc * delta)
		
	velocity = vel_h + vel_v + impulse
	move_and_slide()
	
		
	impulse *= impulse_deacc * delta
	
	#SEND TRANSFORM TO VIEWPORT CAMERA
	if not plugin_camera:
		return
		
	plugin_camera.global_transform = plugin_camera.global_transform.interpolate_with(camera_pos.global_transform, 30.0 * delta)
	call_deferred("send_camera_transform_to_plugin", plugin_camera, camera_pos)
	
	
func send_camera_transform_to_plugin(plugin_camera, camera_pos):
	#SEND TRANSFORM TO VIEWPORT CAMERA
	plugin_camera.global_transform = plugin_camera.global_transform.interpolate_with(camera_pos.global_transform, 0.5)
	
	
func jump():
	if jump_count < jump_limit:
		jump_count += 1
		do_jump = true

func apply_central_impulse(_impulse):
	impulse = _impulse
	floor_snap_length = 0.0
	
func set_gravity_direction(_gravity_direction):
	
	gravity_direction = _gravity_direction
	up_direction = -gravity_direction
	
	var old_basis = global_transform.basis
	var new_basis = global_transform.basis
	new_basis.y = -gravity_direction
	new_basis.z = new_basis.x.cross(new_basis.y)
	
	tween_basis = create_tween()
	tween_basis.tween_method(Callable(self, "basis_slerp").bind(old_basis, new_basis), 0.0, 1.0, 0.3)
	
func basis_slerp(weight:float, old_bas:Basis, new_bas:Basis):
	global_transform.basis = old_bas.slerp(new_bas, weight)


func _on_gravity_area_detector_area_entered(area):
	if area is Gravity_Area:
		gravity_areas.append(-area.global_transform.basis.y)
		set_gravity_direction(gravity_areas.back())


func _on_gravity_area_detector_area_exited(area):
	if area is Gravity_Area:
		gravity_areas.pop_back()
		set_gravity_direction(gravity_areas.back())

func do_set_player(val):
	if not val:
		return
	var player_node = get_node_or_null(player_path)
	if not player_node:
		return
	player_node.global_transform = global_transform
	
