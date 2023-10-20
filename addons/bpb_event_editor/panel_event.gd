@tool
extends VBoxContainer

var le_event : LineEdit
var event_container : VBoxContainer
var event_row_i : PackedScene
var main_window

func _ready():
	pass # Replace with function body.

func fix_size():
	await get_tree().process_frame
	get_child(0).size = size

func get_nodes():
	le_event = $HBoxContainer/le_event
	event_row_i = load("res://addons/bpb_event_editor/event_row.tscn")
	event_container = $ScrollContainer/event_container
	main_window = get_node("../../..")

func _on_btn_clear_button_down():
	get_nodes()
	le_event.text = ""
	le_event.grab_focus()

func _on_le_event_text_submitted(new_text):
	save_new()

func _on_btn_save_button_down():
	save_new()
	
func save_new():
	get_nodes()
	var row = event_row_i.instantiate()
	event_container.add_child(row)
	
	var res = Res_Event.new()
	res.event = le_event.text
	row.set_data(res)
	
	refresh_id()
	
func refresh_id():
	get_nodes()
	for i in event_container.get_child_count():
		var row = event_container.get_child(i)
		row.set_id(i)
	
func get_res_as_array():
	get_nodes()
	var ret = []
	for row in event_container.get_children():
		ret.append(row.res_data)
	return ret
	
func restore_data(_res):
	get_nodes()
	for row in event_container.get_children():
		row.queue_free()
	await get_tree().process_frame
	for r in _res:
		var row = event_row_i.instantiate()
		event_container.add_child(row)
		row.set_data(r)
