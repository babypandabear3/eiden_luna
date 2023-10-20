@tool
extends PanelContainer

signal data_updated

var res_data : Res_Quest

var lbl_quest_name : Label
var log_row_i 
var log_container : VBoxContainer
var timer_save : Timer

func _ready():
	fix_size()
	
func fix_size():
	get_nodes()
	await get_tree().process_frame
	get_child(0).size = size
	

func get_nodes():
	lbl_quest_name = $VBoxContainer/HBoxContainer/lbl_quest_name
	log_container = $VBoxContainer/ScrollContainer/log_container
	log_row_i = load("res://addons/bpb_quest_editor/log_row.tscn")
	timer_save = $timer_save
	
func _log_edit_started(_par):
	get_nodes()
	for row in log_container.get_children():
		row.queue_free()
		
	await get_tree().process_frame
	
	res_data = _par
	lbl_quest_name.text = res_data.quest_name
	
	for i in res_data.logs.size():
		var row = log_row_i.instantiate()
		log_container.add_child(row)
		row.set_data(res_data.logs[i])
		row.log_updated.connect(Callable(self, "_log_updated"))

func _on_btn_new_button_down():
	get_nodes()
	if lbl_quest_name.text == "":
		return
		
	var row = log_row_i.instantiate()
	log_container.add_child(row)
	var res = Res_Log.new().duplicate(true)
	row.set_data(res)
	row.log_updated.connect(Callable(self, "_log_updated"))
	_on_timer_save_timeout()

func _log_updated():
	timer_save.wait_time = 0.3
	timer_save.start()

func update_id():
	get_nodes()
	for i in log_container.get_child_count():
		var row = log_container.get_child(i)
		row.set_id(i)


func _on_timer_save_timeout():
	get_nodes()
	update_id()
	res_data.logs = []
	for row in log_container.get_children():
		res_data.logs.append(row.res_data)
		
	emit_signal("data_updated")
