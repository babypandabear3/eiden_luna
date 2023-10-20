extends PanelContainer


var action := ""
var action_event

@onready var lbl_action = $HBoxContainer/lbl_action
@onready var btn_event = $HBoxContainer/btn_event
@onready var timer_input = $timer_input

var reading_input = false

func _ready():
	pass # Replace with function body.

func set_action(_action):
	action = _action
	lbl_action.text = action
	var events = InputMap.action_get_events(action)
	for e in events:
		var event_as_text = e.as_text()
		if "Joypad" in event_as_text:
			btn_event.text = event_as_text
			action_event = e
			
func set_event(_event):
	btn_event.text = _event.as_text()
	InputMap.action_erase_event(action, action_event)
	action_event = _event
	InputMap.action_add_event(action, action_event)
	
func _on_btn_event_button_down():
	start_reading_input()

func _on_timer_input_timeout():
	stop_reading_input()
	
func start_reading_input():
	reading_input = true
	for obj in get_tree().get_nodes_in_group("keymapper"):
		obj.disabled = true
	timer_input.start()
	
func stop_reading_input():
	reading_input = false
	for obj in get_tree().get_nodes_in_group("keymapper"):
		obj.disabled = false

func _input(event):
	if not reading_input:
		return
		
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		set_event(event)
		stop_reading_input()
	
