class_name Keyring
extends World_Tool

var keys = []
# Called when the node enters the scene tree for the first time.
func _ready():
	type = World_Tool._TYPE.KEYRING
	area_entered.connect(_area_entered)
	area_exited.connect(_area_exited)


func _area_entered(area):
	if area is KeyCard:
		keys.append(area.get_door_id())
		area.taken()
	pass
	
func _area_exited(_area):
	pass
	
func has_door_key(door_id):
	return keys.find(door_id) >= 0
