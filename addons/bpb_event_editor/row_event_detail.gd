@tool
extends PanelContainer

signal event_detail_updated

var le_function : LineEdit
var row_ed_param : PackedScene
var v_container : VBoxContainer
var ob_actor : OptionButton
var chk_wait : CheckBox

var res_data : Res_Event_Detail

func _ready():
	pass # Replace with function body.


func get_nodes():
	ob_actor = $v_container/HBoxContainer2/ob_actor
	v_container = $v_container
	le_function = $v_container/HBoxContainer/le_function
	chk_wait = $v_container/chk_wait
	row_ed_param = load("res://addons/bpb_event_editor/row_event_detail_param.tscn")
	
func _on_btn_param_add_button_down():
	get_nodes()
	var row = row_ed_param.instantiate()
	v_container.add_child(row)
	row.event_detail_param_updated.connect(Callable(self, "_update_params"))

func update_actor(_actors):
	get_nodes()
	
	var selected_actor_text = ""
	if ob_actor.selected >= 0:
		selected_actor_text = ob_actor.get_item_text(ob_actor.selected)
	
	ob_actor.clear()
	
	for i in _actors.size():
		ob_actor.add_item(_actors[i])
		if _actors[i] == selected_actor_text:
			ob_actor.selected = i
		
func set_data(_res):
	get_nodes()
	res_data = _res
	for i in ob_actor.item_count:
		if ob_actor.get_item_text(i) == res_data.actor:
			ob_actor.selected = i
			
	le_function.text = res_data.function
	chk_wait.button_pressed = res_data.wait_finish
	for key in res_data.params.keys():
		_on_btn_param_add_button_down()
		var row = v_container.get_child(v_container.get_child_count()-1)
		row.set_key(key)
		row.set_value(res_data.params[key])
		
func _on_ob_actor_item_selected(index):
	update_res_data()

func _on_le_function_text_changed(new_text):
	update_res_data()

func _update_params():
	update_res_data()
	
func update_res_data():
	get_nodes()
	await get_tree().create_timer(0.1).timeout
	
	res_data.actor = ob_actor.get_item_text(ob_actor.selected)
	res_data.function = le_function.text
	res_data.wait_finish = chk_wait.button_pressed
	var param = {}
	for row in v_container.get_children():
		if row.is_in_group("bpb_event_system_row_event_detail_param"):
			var key = row.get_key()
			var val = row.get_value()
			param[key] = val
	res_data.params = param
	
	emit_signal("event_detail_updated")


func _on_btn_del_button_down():
	emit_signal("event_detail_updated")
	queue_free()


func _on_btn_up_button_down():
	var owner_container = get_parent()
	var idx = get_index()
	if idx > 0:
		owner_container.move_child(self, idx - 1)
	emit_signal("event_detail_updated")

func _on_btn_down_button_down():
	var owner_container = get_parent()
	var idx = get_index()
	if idx < owner_container.get_child_count(-1):
		owner_container.move_child(self, idx + 1)
	emit_signal("event_detail_updated")


func _on_chk_wait_toggled(button_pressed):
	update_res_data()

func param_new():
	var row = row_ed_param.instantiate()
	v_container.add_child(row)
	row.event_detail_param_updated.connect(Callable(self, "_update_params"))
	return row
	
func default_look():
	get_nodes()
	le_function.text = "look_at"
	var row = param_new()
	row.set_key("target")
	update_res_data()

func default_walk():
	get_nodes()
	le_function.text = "walk_to"
	var row = param_new()
	row.set_key("target")
	update_res_data()

func default_anim():
	get_nodes()
	le_function.text = "play_animation"
	var row = param_new()
	row.set_key("animation")
	update_res_data()
	
func default_quest():
	get_nodes()
	le_function.text = "update_quest"
	var row = param_new()
	row.set_key("quest_id")
	
	row = param_new()
	row.set_key("log_id")
	update_res_data()
	
func default_inventory():
	get_nodes()
	le_function.text = "update_inventory"
	var row = param_new()
	row.set_key("item_id")
	
	row = param_new()
	row.set_key("qty")
	update_res_data()
