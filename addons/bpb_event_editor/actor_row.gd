@tool
extends PanelContainer

signal actor_updated

var res_data : Res_Actor

var lbl_id : Label
var le_actor : LineEdit
var main_window

func _ready():
	get_nodes()
	var panel_right = main_window.panel_event_detail
	self.actor_updated.connect(Callable(panel_right, "_actor_updated"))


func get_nodes():
	lbl_id = $HBoxContainer/lbl_id as Label
	le_actor = $HBoxContainer/le_actor as LineEdit
	main_window = get_node("../../../../../..")
	
func set_data(_par):
	get_nodes()
	res_data = _par
	lbl_id.text = str(res_data.id)
	le_actor.text = res_data.actor
	emit_signal("actor_updated")
	
func set_id(_id):
	get_nodes()
	res_data.id = _id
	lbl_id.text = str(res_data.id)
	emit_signal("actor_updated")
	
func _on_le_event_text_changed(new_text):
	res_data.actor = new_text
	main_window.save_to_file()

func _on_btn_del_button_down():
	main_window.save_to_file()
	queue_free()

func _on_btn_up_button_down():
	var owner_container = get_parent()
	var idx = get_index()
	if idx > 0:
		owner_container.move_child(self, idx - 1)
	emit_signal("actor_updated")

func _on_btn_down_button_down():
	var owner_container = get_parent()
	var idx = get_index()
	if idx < owner_container.get_child_count(-1):
		owner_container.move_child(self, idx + 1)
	emit_signal("actor_updated")


func _on_le_actor_text_changed(new_text):
	res_data.actor = new_text
	emit_signal("actor_updated")

