@tool
extends MeshInstance3D

@export var speed : float = 100.0
@export var move_fwd : bool = false :
	set(_value):
		position += -global_transform.basis.z * 100
		move_fwd = false
		print("move")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
