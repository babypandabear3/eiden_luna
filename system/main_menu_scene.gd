extends Node

const MAIN_PATH : String = "res://game/main.tscn"
@export var top_menu_path : NodePath

@onready var main_menu = $main_menu
@onready var option_menu = $option_menu
@onready var control_menu = $control_menu

var menu_list = {}

var top_menu

func _ready():
	top_menu = get_node_or_null(top_menu_path)
	ResourceLoader.load_threaded_request(MAIN_PATH)
	
	for o in get_children():
		menu_list[o.name] = o
		if menu_list[o.name] is PanelContainer:
			menu_list[o.name].main_scene = self
	
	show_top_menu()
	
func show_top_menu():
	show_menu("main_game")
	top_menu.show()
	
func start_new_game():
	var main_scene = ResourceLoader.load_threaded_get(MAIN_PATH)
	var main = main_scene.instantiate()
	get_tree().root.add_child(main)
	GameState.gamestate = GameState._STATE.GAMEPLAY
	queue_free()

func show_menu(menu_name):
	for k in menu_list.keys():
		if menu_list[k] is PanelContainer:
			if k == menu_name:
				menu_list[k].show()
			else:
				menu_list[k].hide()
	

