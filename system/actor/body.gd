class_name Body
extends CharacterBody3D

@export var use_custom_gravity := false
@export var direction = Vector3.ZERO
@export var SPEED := 5.0
@export var JUMP_VELOCITY := 8.0
@export var gravity_modifier_up := 1.5
@export var gravity_modifier_down := 2.0
@export var coyote_time := 0.1
@export var jump_limit := 2
@export var acc := 15
@export var deacc := 50
@export var impulse_deacc := 55

var gravity_direction := Vector3.DOWN
var airborne := 0.0
var jump_count := 0
var impulse := Vector3.ZERO
var do_jump := false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var tween_basis : Tween
var gravity_area_detector = preload("res://system/actor/gravity_area_detector.tscn")

func _ready():
	if use_custom_gravity:
		var obj = gravity_area_detector.instantiate()
		add_child(obj)

func _physics_process(delta):
	
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
		vel_v = -gravity_direction * JUMP_VELOCITY
		jump_count += 1
		do_jump = false
		
	if direction:
		var motion_h = direction.slide(gravity_direction).normalized() * acc * delta
		vel_h += motion_h
		vel_h = vel_h.limit_length(SPEED)
	else:
		vel_h = lerp(vel_h, Vector3.ZERO, deacc * delta)
		
	velocity = vel_h + vel_v + impulse
	move_and_slide()
	
	impulse *= impulse_deacc * delta

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
	new_basis.y = -gravity_direction
	new_basis.z = new_basis.x.cross(new_basis.y)
	
	tween_basis = create_tween()
	tween_basis.tween_method(Callable(self, "basis_slerp").bind(old_basis, new_basis), 0.0, 1.0, 0.3)
	
func basis_slerp(weight:float, old_bas:Basis, new_bas:Basis):
	global_transform.basis = old_bas.slerp(new_bas, weight)
