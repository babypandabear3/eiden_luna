@tool
extends PanelContainer

var res_data : Res_Event

var lbl_id : Label
var le_event : LineEdit
var main_window
var panel_right
	
func _ready():
	pass # Replace with function body.


func get_nodes():
	lbl_id = $HBoxContainer/lbl_id as Label
	le_event = $HBoxContainer/le_event as LineEdit
	main_window = get_node("../../../../../..")
	panel_right = main_window.panel_event_detail
	
func set_data(_par):
	get_nodes()
	res_data = _par
	lbl_id.text = str(res_data.id)
	le_event.text = res_data.event
	
func set_id(_id):
	get_nodes()
	res_data.id = _id
	lbl_id.text = str(res_data.id)
	
func _on_le_event_text_changed(new_text):
	res_data.event = new_text
	main_window.save_to_file()

func _on_btn_del_button_down():
	main_window.save_to_file()
	queue_free()


func _on_btn_up_button_down():
	var owner_container = get_parent()
	var idx = get_index()
	if idx > 0:
		owner_container.move_child(self, idx - 1)


func _on_btn_down_button_down():
	var owner_container = get_parent()
	var idx = get_index()
	if idx < owner_container.get_child_count(-1):
		owner_container.move_child(self, idx + 1)


func _on_btn_edit_button_down():
	get_nodes()
	panel_right.set_data(res_data)
