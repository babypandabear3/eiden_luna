extends Node3D

@export var target_path : NodePath
var target : Node3D
# Called when the node enters the scene tree for the first time.
func _ready():
	if not target:
		target = get_node_or_null(target_path)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if not target:
		return
		
	global_transform = target.global_transform
