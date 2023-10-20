class_name Res_Schedule_Task
extends Resource

enum _TASK {
	SLEEP,
	GUARD,
}

enum _LOCATION {
	HOME,
	GATE_EAST,
	GATE_WEST,
}

@export var task : _TASK = _TASK.SLEEP
@export var location : _LOCATION = _LOCATION.HOME
