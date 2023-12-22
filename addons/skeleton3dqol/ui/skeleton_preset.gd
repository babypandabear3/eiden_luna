@tool
extends HBoxContainer

@export var label : String = "" :
	set(value):
		label = value
		_set_label(value)

var RES_FILE :String
var res : ResSkeletonGeneric

func _ready():
	RES_FILE = "res://addons/skeleton3dqol/preset" + label + ".res"
	#if FileAccess.file_exists(filename):
	#	res = ResourceLoader(filename)

func _set_label(value):
	$lbl_setup_no.text = value


func _on_btn_load_button_up():
	load_inputmap_from_file()
	pass # Replace with function body.


func _on_btn_save_button_up():
	res = get_parent().get_parent().get_val_as_res()
	save_inputmap_to_file()

func save_inputmap_to_file():
	#save resource to file
	if FileAccess.file_exists(RES_FILE):
		DirAccess.remove_absolute(RES_FILE)
	ResourceSaver.save(res, RES_FILE)
	print(RES_FILE)

func load_inputmap_from_file():
	if FileAccess.file_exists(RES_FILE):
		#load resource from file
		res = ResourceLoader.load(RES_FILE)
		get_parent().get_parent().set_res_to_spinboxes(res)
