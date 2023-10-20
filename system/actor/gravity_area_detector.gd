extends Area3D

var gravity_areas = []
# Called when the node enters the scene tree for the first time.
func _ready():
	gravity_areas.append(Vector3.DOWN)


func _on_area_entered(area):
	if area is Gravity_Area:
		gravity_areas.append(-area.global_transform.basis.y)
		get_parent().set_gravity_direction(gravity_areas.back())


func _on_area_exited(area):
	if area is Gravity_Area:
		gravity_areas.pop_back()
		get_parent().set_gravity_direction(gravity_areas.back())
