extends Node

var camera : Camera3D
var body : CharacterBody3D
var direction = Vector3.ZERO

func _ready():
	camera = get_viewport().get_camera_3d()
	body = get_parent()


func _physics_process(_delta):
	if not body:
		return
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		body.jump()

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	body.direction = direction
