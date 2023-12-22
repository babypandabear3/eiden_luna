# meta-description: Base template for Node with default Godot cycle methods
extends World_Tool

@onready var hfsm = $HFSM
# Called when the node enters the scene tree for the first time.
func _ready():
	type = _TYPE.DOOR_AUTOMATIC
	

func _sensor_entered(area):
	DEBUG._print("entered " + area.name)
	#if area.is_in_group("player_foot_sensor"):
	
	
func _sensor_exited(area):
	#if area.is_in_group("player_foot_sensor"):
	DEBUG._print("exited "+ area.name)
