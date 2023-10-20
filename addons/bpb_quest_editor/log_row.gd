@tool
extends PanelContainer

signal log_updated

var res_data : Res_Log

var lbl_id : Label
var te_log_text : TextEdit

func _ready():
	pass # Replace with function body.

func get_nodes():
	lbl_id = $HBoxContainer/lbl_id
	te_log_text = $HBoxContainer/te_log_text

func set_data(_res):
	get_nodes()
	res_data = _res
	lbl_id.text = res_data.id
	te_log_text.text = res_data.log_text
	
func set_id(_id):
	get_nodes()
	res_data.id = str(_id)
	lbl_id.text = res_data.id

func _on_btn_del_button_down():
	emit_signal("log_updated")
	queue_free()

func _on_btn_up_button_down():
	emit_signal("log_updated")
	var owner_container = get_parent()
	var idx = get_index()
	if idx > 0:
		owner_container.move_child(self, idx - 1)


func _on_btn_down_button_down():
	emit_signal("log_updated")
	var owner_container = get_parent()
	var idx = get_index()
	if idx < owner_container.get_child_count()-1:
		owner_container.move_child(self, idx + 1)


func _on_te_log_text_text_changed():
	get_nodes()
	res_data.log_text = te_log_text.text
	emit_signal("log_updated")
