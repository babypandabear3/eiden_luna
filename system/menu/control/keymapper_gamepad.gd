extends PanelContainer

var main_logic : PanelContainer
var actions : Array
var row_i

@export_enum("Gamepad", "Keyboard/Mouse") var input_device: int = 0
@onready var row_container = $ScrollContainer/VBoxContainer

func _ready():
	if input_device == 0:
		row_i = preload("res://system/menu/control/keymapper_gamepad_row.tscn")
	else:
		row_i = preload("res://system/menu/control/keymapper_kbm_row.tscn")

func setup(_actions):
	actions = _actions
	for act in actions:
		var row = row_i.instantiate()
		row_container.add_child(row)
		row.set_action(act)
