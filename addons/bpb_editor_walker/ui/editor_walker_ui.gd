@tool
extends HBoxContainer

var plugin_main
var walker_enabled = false

@onready var button := $cb_enable_walker
@onready var focus_holder := $focus_holder


func _on_cb_enable_walker_toggled(button_pressed):
	if plugin_main.can_be_activated():
		set_active(button_pressed)
	

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ENTER and event.alt_pressed and event.ctrl_pressed:
			if plugin_main.can_be_activated():
				button.button_pressed = not button.button_pressed
				set_active(button.button_pressed)
		focus_holder.clear()

func set_active(par):
	walker_enabled = par
	if par:
		focus_holder.show()
		focus_holder.grab_focus()
		focus_holder.grab_click_focus()
		plugin_main.start_walk()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		focus_holder.text = ""
		focus_holder.hide()
		plugin_main.end_walk()
	pass
