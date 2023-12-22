extends World_Tool

var door : Node3D
# Called when the node enters the scene tree for the first time.
func _ready():
	type = _TYPE.KEY_STEP_ON
	door = get_parent()

