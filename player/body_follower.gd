extends Marker3D

var target = null

func _ready():
	pass
	
func _physics_process(delta):
	if target:
		global_position = global_position.lerp(target.global_position, 0.5)
