class_name PlayerSensor
extends Node3D

signal jump_pod_entered
signal punched_to_ragdoll_entered

@onready var ray_chest : RayCast3D = $sensor_ledge_hanging/ray_chest
@onready var ray_head : RayCast3D = $sensor_ledge_hanging/ray_head
@onready var ray_ledge_top : RayCast3D =  $sensor_ledge_hanging/ray_ledge_top
@onready var ray_ledge_left : RayCast3D = $sensor_ledge_hanging/ray_ledge_left
@onready var ray_ledge_right : RayCast3D = $sensor_ledge_hanging/ray_ledge_right

@onready var ray_hanging_rotate_left : RayCast3D = $sensor_wall_climb/ray_hanging_rotate_left
@onready var ray_hanging_rotate_right : RayCast3D = $sensor_wall_climb/ray_hanging_rotate_right
@onready var ray_body_side_left : RayCast3D = $sensor_wall_climb/ray_body_side_left
@onready var ray_body_side_right : RayCast3D = $sensor_wall_climb/ray_body_side_right

@export var state_machine_path : NodePath

@onready var wall_climb_ray_chest := $sensor_wall_climb/ray_chest
@onready var wall_climb_ray_head := $sensor_wall_climb/ray_head
@onready var wall_climb_ray_top := $sensor_wall_climb/ray_top
@onready var wall_climb_ray_left := $sensor_wall_climb/ray_left
@onready var wall_climb_ray_right := $sensor_wall_climb/ray_right

var hanging_possible_frame_count := 0
var wallrun_possible_frame_count := 0
var wall_hanging_possible_frame_count := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var state_machine = get_node_or_null(state_machine_path)
	if state_machine:
		state_machine.blackboard["sensor"] = self

func _physics_process(_delta):
	update_raycast(ray_chest)
	update_raycast(ray_head)
	update_raycast(ray_ledge_top)
	update_raycast(ray_ledge_left)
	update_raycast(ray_ledge_right)
	
	if not ray_head_colliding() and ray_chest_colliding():
		hanging_possible_frame_count += 1
	else:
		hanging_possible_frame_count = 0
	
	if ray_chest_colliding():
		wallrun_possible_frame_count += 1
	else:
		wallrun_possible_frame_count = 0
		
	if not wall_climb_ray_head.is_colliding() and wall_climb_ray_chest.is_colliding():
		wall_hanging_possible_frame_count += 1
	else:
		wall_hanging_possible_frame_count = 0
	
func update_raycast(ray):
	ray.force_update_transform()
	ray.force_raycast_update()
	
func ray_chest_colliding():
	return ray_chest.is_colliding()
	
func ray_chest_normal():
	return ray_chest.get_collision_normal()
	
func ray_head_colliding():
	return ray_head.is_colliding()
	
func ray_ledge_top_colliding():
	return ray_ledge_top.is_colliding
	
func ray_ledge_collision_point():
	return ray_ledge_top.get_collision_point()

func get_ledge_hanging_v_adjustment():
	if ray_ledge_top_colliding():
		return (ray_ledge_top.global_position.distance_to(ray_ledge_top.get_collision_point())) - 0.62
	else:
		return 0.0

func ray_ledge_left_colliding():
	return ray_ledge_left.is_colliding()

func ray_ledge_right_colliding():
	return ray_ledge_right.is_colliding()

func hanging_is_possible():
	return hanging_possible_frame_count > 1

func wallrun_is_possible():
	return wallrun_possible_frame_count > 1

func _on_foot_area_entered(area):
	match area.type:
		World_Tool._TYPE.JUMP_POD:
			jump_pod_entered.emit()
		World_Tool._TYPE.PUNCH_TO_RAGDOLL:
			punched_to_ragdoll_entered.emit(area)
			
func _on_foot_area_exited(area):
	match area.type:
		World_Tool._TYPE.PUNCH_TO_RAGDOLL:
			pass

func can_wall_hanging():
	if wall_hanging_possible_frame_count > 1:
		return true
	else:
		return false

func get_wall_hanging_v_adjustment():
	if wall_climb_ray_top.is_colliding():
		return (wall_climb_ray_top.global_position.distance_to(wall_climb_ray_top.get_collision_point())) - 0.62
	else:
		return 0.0
		
func ray_wall_climbing_left_colliding():
	return wall_climb_ray_left.is_colliding()

func ray_wall_climbing_right_colliding():
	return wall_climb_ray_right.is_colliding()

func get_hanging_rotate_left_normal():
	var ret = Vector3.ZERO
	if ray_hanging_rotate_left.is_colliding():
		ret = ray_hanging_rotate_left.get_collision_normal()
	return ret
	
func get_hanging_rotate_right_normal():
	var ret = Vector3.ZERO
	if ray_hanging_rotate_right.is_colliding():
		ret = ray_hanging_rotate_right.get_collision_normal()
	return ret


func is_ray_body_side_left_colliding():
	return ray_body_side_left.is_colliding()
	
func is_ray_body_side_right_colliding():
	return ray_body_side_right.is_colliding()
