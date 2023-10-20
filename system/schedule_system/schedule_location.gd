class_name Schedule_Action
extends Marker3D

enum _LOCATION {
	HOME,
	STORE,
	RESTAURANT,
	ACADEMY,
}

enum _ACTION {
	GO_HOME,
	WORK,
	BUY_MEAT,
	BUY_VEGETABLE,
	EAT,
	DRINK,
}

@export var location : _LOCATION = _LOCATION.HOME
@export var action0 : _ACTION = _ACTION.WORK


func _ready():
	pass # Replace with function body.

