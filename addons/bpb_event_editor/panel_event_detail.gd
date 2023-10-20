@tool
extends PanelContainer

var lbl_event : Label
var row_event_detail : PackedScene
var event_detail_container : VBoxContainer
var main_window

var res_data : Res_Event

func _ready():
	pass # Replace with function body.

func get_nodes():
	lbl_event = $VBoxContainer/lbl_event
	row_event_detail = load("res://addons/bpb_event_editor/row_event_detail.tscn")
	event_detail_container = $VBoxContainer/ScrollContainer/event_detail_container
	main_window = get_node("../..")
	
func set_data(_par):
	get_nodes()
	res_data = _par
	lbl_event.text = res_data.event
	
	for row in event_detail_container.get_children():
		row.queue_free()
		
	await get_tree().process_frame
	
	for res in res_data.details:
		var row = make_generic()
		row.set_data(res)
	
func make_generic():
	get_nodes()
	var row = row_event_detail.instantiate()
	event_detail_container.add_child(row)
	_actor_updated()
	row.event_detail_updated.connect(Callable(self, "_event_detail_updated"))
	return row

func set_default_res(row):
	var res = Res_Event_Detail.new()
	row.set_data(res)

func _on_btn_generic_button_down():
	get_nodes()
	if lbl_event.text == "":
		return
	var row = make_generic()
	set_default_res(row)
	_event_detail_updated()
	
func _on_btn_look_button_down():
	get_nodes()
	if lbl_event.text == "":
		return
	var row = make_generic()
	set_default_res(row)
	row.default_look()
	_event_detail_updated()


func _on_btn_walk_button_down():
	get_nodes()
	if lbl_event.text == "":
		return
	var row = make_generic()
	set_default_res(row)
	row.default_walk()
	_event_detail_updated()


func _on_btn_anim_button_down():
	get_nodes()
	if lbl_event.text == "":
		return
	var row = make_generic()
	set_default_res(row)
	row.default_anim()
	_event_detail_updated()


func _on_btn_quest_button_down():
	get_nodes()
	if lbl_event.text == "":
		return
	var row = make_generic()
	set_default_res(row)
	row.default_quest()
	_event_detail_updated()


func _on_btn_inventory_button_down():
	get_nodes()
	if lbl_event.text == "":
		return
	var row = make_generic()
	set_default_res(row)
	row.default_inventory()
	_event_detail_updated()

func _actor_updated():
	get_nodes()
	var actors = []
	for row in get_tree().get_nodes_in_group("bpb_event_system_actor_row"):
		actors.append(row.res_data.actor)
	for row in event_detail_container.get_children():
		if row.is_in_group("bpb_event_system_row_event_detail"):
			row.update_actor(actors)

func _event_detail_updated():
	await get_tree().create_timer(0.1).timeout
	get_nodes()
	res_data.details = []
	for row in event_detail_container.get_children():
		res_data.details.append(row.res_data)
	
	main_window.save_to_file()
