class_name Body
extends CharacterBody3D

enum _MOTION_STATE {
	WALK,
	FLY,
	SWIM,
	ROOT_MOTION,
}
@onready var motion_state  = _MOTION_STATE.WALK

@export var use_custom_gravity := false
@export var direction = Vector3.ZERO
@export var SPEED := 5.0
@export var JUMP_VELOCITY := 8.0
@export var gravity_modifier_up := 1.5
@export var gravity_modifier_down := 2.0
@export var coyote_time := 0.1
@export var jump_limit := 2
@export var acc := 15.0
@export var deacc := 50.0
@export var impulse_deacc := 55.0
@export var horizontal_speed_scale := 1.0
@export var vertical_speed_scale := 1.0
@export var gravity_scale := 1.0

var root_motion_velocity := Vector3.ZERO
var gravity_direction := Vector3.DOWN
var airborne := 0.0
var jump_count := 0
var impulse := Vector3.ZERO
var do_jump := false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var tween_basis : Tween
var gravity_area_detector = preload("res://system/actor/gravity_area_detector.tscn")

var default_vars = {}
var jump_is_released = false

func _ready():
	floor_constant_speed = true
	floor_snap_length = 0.3
	
	if use_custom_gravity:
		var obj = gravity_area_detector.instantiate()
		add_child(obj)
	
	save_default_var()
	
func save_default_var():
	default_vars = {}
	default_vars["use_custom_gravity"] = use_custom_gravity
	default_vars["direction"] = direction
	default_vars["SPEED"] = SPEED
	default_vars["JUMP_VELOCITY"] = JUMP_VELOCITY
	default_vars["gravity_modifier_up"] = gravity_modifier_up
	default_vars["gravity_modifier_down"] = gravity_modifier_down
	default_vars["coyote_time"] = coyote_time
	default_vars["jump_limit"] = jump_limit
	default_vars["acc"] = acc
	default_vars["deacc"] = deacc
	default_vars["impulse_deacc"] = impulse_deacc
	default_vars["horizontal_speed_scale"] = horizontal_speed_scale
	default_vars["vertical_speed_scale"] = vertical_speed_scale
	default_vars["gravity_scale"] = gravity_scale
	
func load_default_vars():
	use_custom_gravity = default_vars["use_custom_gravity"] 
	direction = default_vars["direction"] 
	SPEED = default_vars["SPEED"] 
	JUMP_VELOCITY = default_vars["JUMP_VELOCITY"] 
	gravity_modifier_up = default_vars["gravity_modifier_up"] 
	gravity_modifier_down = default_vars["gravity_modifier_down"] 
	coyote_time = default_vars["coyote_time"] 
	jump_limit = default_vars["jump_limit"] 
	acc = default_vars["acc"] 
	deacc = default_vars["deacc"] 
	impulse_deacc = default_vars["impulse_deacc"] 
	horizontal_speed_scale = default_vars["horizontal_speed_scale"] 
	vertical_speed_scale = default_vars["vertical_speed_scale"] 
	gravity_scale = default_vars["gravity_scale"] 

func _physics_process(delta):
	match motion_state:
		_MOTION_STATE.WALK:
			do_walk(delta)
		_MOTION_STATE.FLY:
			do_fly(delta)
		_MOTION_STATE.SWIM:
			do_swim(delta)
		_MOTION_STATE.ROOT_MOTION:
			do_root_motion(delta)
	
func do_walk(delta):
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
		vel_v *= gravity_scale
		
		floor_snap_length = 0.0
		airborne += delta
		if airborne > coyote_time and jump_count == 0:
			jump_count += 1
		
	if do_jump:
		vel_v = -gravity_direction * JUMP_VELOCITY
		jump_count += 1
		do_jump = false
		
	if jump_is_released:
		jump_is_released = false
		if vel_v.dot(-gravity_direction) > 0:
			vel_v *= 0.5
			
	if direction:
		var motion_h = direction.slide(gravity_direction).normalized() * acc * delta
		vel_h += motion_h
		vel_h = vel_h.limit_length(SPEED)
	else:
		vel_h = lerp(vel_h, Vector3.ZERO, deacc * delta)

	velocity = (vel_h * horizontal_speed_scale) + (vel_v * vertical_speed_scale) + impulse
	move_and_slide()
	
	impulse *= impulse_deacc * delta
	
func do_fly(delta):
	var vel = velocity
	if direction:
		vel += direction.normalized()
		vel = vel.limit_length(SPEED)
	else:
		vel = lerp(vel, Vector3.ZERO, deacc * delta)
	velocity = vel + impulse
	move_and_slide()
	
	impulse *= impulse_deacc * delta
	
func do_swim(_delta):
	pass
	
func do_root_motion(_delta):
	velocity = root_motion_velocity
	move_and_slide()
	
func reset_root_motion_velocity():
	root_motion_velocity = Vector3.ZERO

func walk_entering():
	motion_state = _MOTION_STATE.WALK
	
func fly_entering():
	motion_state = _MOTION_STATE.FLY
	
func swim_entering():
	motion_state = _MOTION_STATE.SWIM
	
func root_motion_entering():
	motion_state = _MOTION_STATE.ROOT_MOTION
	
func set_root_motion_velocity(_par : Vector3 = Vector3.ZERO):
	root_motion_velocity = _par
	
func try_jump():
	if jump_count < jump_limit:
		do_jump = true
		return true
	else:
		return false
	
func apply_central_impulse(_impulse):
	impulse = _impulse
	floor_snap_length = 0.0
	
func set_gravity_direction(_gravity_direction):
	gravity_direction = _gravity_direction
	up_direction = -gravity_direction
	
	var old_basis = global_transform.basis
	var new_basis = global_transform.basis
	new_basis.x = new_basis.x.slide(up_direction).normalized()
	new_basis.y = up_direction
	new_basis.z = new_basis.z.slide(up_direction).normalized()
	new_basis = new_basis.orthonormalized()
	global_transform.basis = old_basis.slerp(new_basis, 0.1)
	
	tween_basis = create_tween()
	tween_basis.tween_method(Callable(self, "basis_slerp").bind(old_basis, new_basis), 0.0, 1.0, 0.3)
	
func basis_slerp(weight:float, old_bas:Basis, new_bas:Basis):
	global_transform.basis = old_bas.slerp(new_bas, weight)

func walljump_override(_dir):
	velocity = (_dir * SPEED) + (-gravity_direction * JUMP_VELOCITY)
	direction = _dir
	jump_count = 1
	
func hanging_override(_dir):
	velocity = _dir.slide(-gravity_direction).normalized() * 0.1
	direction = _dir
	gravity_scale = 0.0
	#SPEED = 0.5

func velocity_zeroed():
	velocity = Vector3.ZERO
	
func jump_released():
	jump_is_released = true
