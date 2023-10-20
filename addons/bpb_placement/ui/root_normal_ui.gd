@tool
extends PanelContainer

var editor_interface : EditorInterface

@onready var lbl_mode := $VBoxContainer/HBoxContainer/lbl_mode
@onready var tab := $VBoxContainer/TabContainer
var SAVEPATH = "res://addons/bpb_placement/ui/root_normal_ui_data.tres"

func _ready():
	#Res_Root_Normal_UI.new()
	pass # Replace with function body.
	load_from_file()
	
func load_from_file():
	if ResourceLoader.exists(SAVEPATH):
		var res_data = load(SAVEPATH) as Res_Root_Normal_UI
		var new_tab_i = load("res://addons/bpb_placement/ui/root_normal_tab.tscn")
		for d in res_data.data:
			var new_tab = new_tab_i.instantiate()
			tab.add_child(new_tab)
			new_tab.editor_interface = editor_interface
			new_tab.set_data_from_save(d)

func save_to_file():
	var res_data = Res_Root_Normal_UI.new()
	for o in tab.get_children():
		res_data.data.append(o.get_data_to_save())
	ResourceSaver.save(res_data, SAVEPATH)
	

func _on_btn_new_tab_button_down():
	var new_tab = load("res://addons/bpb_placement/ui/root_normal_tab.tscn").instantiate()
	tab.add_child(new_tab)
	new_tab.editor_interface = editor_interface


func _on_tab_container_tab_changed(_tab):
	for o in tab.get_children():
		o.disable_placement()
	
	pass # Replace with function body.
	
func get_placement_options():
	if tab.get_child_count() == 0:
		return {}
	else:
		return tab.get_current_tab_control().get_placement_options()

func set_mode_text(_par):
	lbl_mode.text = _par


func _on_tree_exiting():
	save_to_file()
	
func toggle_placement():
	tab.get_child(tab.current_tab).toggle_placement()
