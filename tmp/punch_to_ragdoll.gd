extends World_Tool

@export var force :float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready():
	type = _TYPE.PUNCH_TO_RAGDOLL


func get_push_force():
	return force
