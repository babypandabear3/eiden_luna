@tool
class_name BPB_RootNormalUI
extends PanelContainer

var files = []

var editor_interface : EditorInterface



var last_selected_path = ""

@onready var context_menu : PopupMenu = $PopupMenu
@onready var item_list : ItemList = $vbox/HBoxContainer/ItemList
@onready var chk_align_y := $vbox/HBoxContainer/PanelContainer/VBoxContainer/chk_align_y
@onready var chk_rand_x := $vbox/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/chk_rand_x
@onready var chk_rand_y := $vbox/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/chk_rand_y
@onready var chk_rand_z := $vbox/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/chk_rand_z
@onready var sb_scale_min := $vbox/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/sb_scale_min
@onready var sb_scale_max := $vbox/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer2/sb_scale_max

@onready var btn_active = $vbox/hbox_menu/btn_active
@onready var le_tab_name = $vbox/hbox_menu/le_tab_name
@onready var sb_column = $vbox/hbox_menu/sb_column

func _ready():
	context_menu.index_pressed.connect(Callable(self, "_on_context_menu_index_pressed"))

func toggle_placement():
	btn_active.button_pressed = not btn_active.button_pressed
	
func enable_placement():
	btn_active.button_pressed = true

func disable_placement():
	btn_active.button_pressed = false

func _on_btn_add_asset_button_down():
	var dialog = EditorFileDialog.new()
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	dialog.display_mode = EditorFileDialog.DISPLAY_LIST
	dialog.add_filter("*.tscn, *.scn; Scenes")
	add_child(dialog)
	dialog.show()
	dialog.invalidate()
	
	dialog.file_selected.connect(Callable(self, "update_file"))
	dialog.files_selected.connect(Callable(self, "update_files"))


func update_file(path):
	files.clear()
	files.append(path)
	update_item_list()
	
func update_files(paths):
	files.clear()
	for p in paths:
		files.append(p)
	update_item_list()

func update_item_list():
	var arr_tmp = []
	for i in item_list.get_item_count():
		arr_tmp.append(item_list.get_item_tooltip(i))
	for path in files:
		if not arr_tmp.has(path):
			item_list.add_item(path)
			var i = item_list.get_item_count()-1
			item_list.set_item_tooltip(i, path)
	
	#WAIT UNTIL ENTERING READY STATE ALLOWING resource_preview VALUE TO BE VALID BEFORE REQUESTING THUMBNAIL IMAGE
	print("new scene(s) added to list")
	for path in files:
		get_preview(path)
		
func get_preview(path):
	pass
	if not editor_interface:
		return
	var resource_preview = editor_interface.get_resource_previewer()
	resource_preview.queue_resource_preview(path, self, "_on_resource_preview", null)
	
func _on_resource_preview(path, texture, thumbnail, user_data):
	for i in item_list.get_item_count():
		if item_list.get_item_text(i) == path:
			item_list.set_item_icon(i, texture)
			item_list.set_item_text(i, "")
			item_list.set_item_text(i, path)

func _on_le_tab_name_text_submitted(new_text):
	name = new_text

func _on_item_list_item_selected(index):
	last_selected_path = item_list.get_item_text(index)
	pass # Replace with function body.

func get_placement_options():
	var ret = {}
	ret["placement_active"] = btn_active.button_pressed
	ret["tab_name"] = le_tab_name.text
	ret["itemlist_column"] = sb_column.value
	
	ret["align_y"] = chk_align_y.button_pressed
	ret["rand_rotate_x"] = chk_rand_x.button_pressed
	ret["rand_rotate_y"] = chk_rand_y.button_pressed
	ret["rand_rotate_z"] = chk_rand_z.button_pressed
	ret["scale_min"] = sb_scale_min.value
	ret["scale_max"] = sb_scale_max.value
	ret["last_selected_path"] = last_selected_path
	return ret

func _on_context_menu_index_pressed(index):
	if index == 0: #remove
		item_list.remove_item(item_list.get_selected_items()[0])
	elif index == 1: #clear
		item_list.clear()


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var pos = get_viewport().get_mouse_position()
		context_menu.position = pos
		context_menu.popup()


func _on_sb_column_value_changed(value):
	item_list.max_columns = value
	pass # Replace with function body.

func get_data_to_save():
	var data_to_save = get_placement_options()
	var item_list_items = []
	for i in item_list.item_count:
		item_list_items.append(item_list.get_item_text(i))
	data_to_save["item_list_items"] = item_list_items
	return data_to_save

func set_data_from_save(data):
	le_tab_name.text = data["tab_name"]
	name = le_tab_name.text
	sb_column.value = data["itemlist_column"]
	
	chk_align_y.button_pressed = data["align_y"]
	chk_rand_x.button_pressed = data["rand_rotate_x"]
	chk_rand_y.button_pressed = data["rand_rotate_y"]
	chk_rand_z.button_pressed = data["rand_rotate_z"]
	sb_scale_min.value = data["scale_min"]
	sb_scale_max.value = data["scale_max"]
	
	update_files(data["item_list_items"])


func _on_btn_delete_this_tab_button_down():
	btn_active.button_pressed = false
	queue_free()
