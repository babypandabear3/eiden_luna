@tool
extends PanelContainer

signal data_updated
signal log_edit_started

var res_data : Res_Quest

var panel : Panel
var lbl_id : Label
var le_quest : LineEdit
var container : HBoxContainer
var owner_container : VBoxContainer

func _ready():
	pass
	
func get_nodes():
	lbl_id = $HBoxContainer/lbl_id
	le_quest = $HBoxContainer/le_quest
	
	
func set_data(_par):
	get_nodes()
	res_data = _par
	lbl_id.text = res_data.id
	le_quest.text = res_data.quest_name
	
func set_id(_par):
	get_nodes()
	res_data.id = _par
	lbl_id.text = _par


func _on_btn_del_button_down():
	emit_signal("data_updated")
	queue_free()


func _on_btn_down_button_down():
	emit_signal("data_updated")
	get_nodes()
	owner_container = get_parent()
	var idx = get_index()
	if idx < owner_container.get_child_count()-1:
		owner_container.move_child(self, idx + 1)


func _on_btn_up_button_down():
	emit_signal("data_updated")
	get_nodes()
	owner_container = get_parent()
	var idx = get_index()
	if idx > 0:
		owner_container.move_child(self, idx - 1)


func _on_btn_edit_button_down():
	emit_signal("log_edit_started", res_data)
	

func _on_le_quest_text_changed(new_text):
	res_data.quest_name = new_text
	emit_signal("data_updated")
