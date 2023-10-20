@tool
extends PanelContainer

var le_quest_name : LineEdit
var vbox_quest_list : VBoxContainer
var quest_row_i
var timer_save : Timer
var log_panel : PanelContainer

var res_data : Res_Quest_System

var SAVEPATH = "res://data/bpb_quest_data.tres"

func _ready():
	res_data = Res_Quest_System.new().duplicate(true)
	fix_size()
	await get_tree().process_frame
	get_nodes()
	log_panel.data_updated.connect(Callable(self, "_on_timer_save_timeout")) #connect signal from log_panel allowing log_panel to start saving to file
	
	load_from_file()

func fix_size():
	get_nodes()
	await get_tree().process_frame
	get_child(0).size = size
	
func get_nodes():
	le_quest_name = $VBoxContainer/HBoxContainer/le_quest_name
	vbox_quest_list = $VBoxContainer/ScrollContainer/vbox_quest_list
	quest_row_i = load("res://addons/bpb_quest_editor/quest_row.tscn")
	timer_save = $timer_save
	timer_save.one_shot = true
	log_panel = get_parent().log_panel

func _on_btn_add_button_down():
	get_nodes()
	le_quest_name.text = ""
	le_quest_name.grab_focus()

func _on_btn_save_button_down():
	get_nodes()
	quest_insert()
	
func quest_insert():
	get_nodes()
	var row = quest_row_i.instantiate()
	var res : Res_Quest = Res_Quest.new().duplicate(true)
	res.id = str(vbox_quest_list.get_child_count()) 
	res.quest_name = le_quest_name.text
	row.set_data(res)
	row.data_updated.connect(Callable(self, "_data_updated"))
	row.log_edit_started.connect(Callable(log_panel, "_log_edit_started"))
	vbox_quest_list.add_child(row)
	_data_updated()
	
func quest_update():
	get_nodes()

func refresh_id():
	get_nodes()
	for i in vbox_quest_list.get_child_count():
		var row = vbox_quest_list.get_child(i)
		row.set_id(str(i))

func _on_le_quest_name_text_submitted(new_text):
	_on_btn_save_button_down()
	
func _data_updated():
	timer_save.wait_time = 0.3
	timer_save.start()

func _on_timer_save_timeout():
	refresh_id()
	
	res_data.quests = []
	for row in vbox_quest_list.get_children():
		res_data.quests.append(row.res_data)
	
	ResourceSaver.save(res_data, SAVEPATH)
	print("quest data saved")


func load_from_file():
	get_nodes()
	if ResourceLoader.exists(SAVEPATH):
		res_data = load(SAVEPATH) as Res_Quest_System
		
		for d in res_data.quests:
			var row = quest_row_i.instantiate()
			row.set_data(d)
			row.data_updated.connect(Callable(self, "_data_updated"))
			row.log_edit_started.connect(Callable(log_panel, "_log_edit_started"))
			vbox_quest_list.add_child(row)
