class_name Lock_N_Key_Model_Door
extends Node3D

@onready var door = $door

@export var pos_opened : Vector3 = Vector3(0.0, 6.5, 0.0)
@export var pos_closed : Vector3 = Vector3(0.0, 0.0, 0.0)

func _ready():
	pass

func closing():
	var tween = create_tween()
	tween.tween_property(door, "position", pos_closed, 0.5)
	
func opening():
	var tween = create_tween()
	tween.tween_property(door, "position", pos_opened, 0.5)

func closed():
	door.position = pos_closed
	
func opened():
	door.position = pos_opened
