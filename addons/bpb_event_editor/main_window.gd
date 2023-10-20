@tool

extends PanelContainer

var panel_event
var panel_actor
var panel_event_detail


var res_data = Res_Event_System
var SAVEPATH = "res://data/bpb_event_data.tres"

func _ready():
	get_nodes()
	load_from_file()
	
func get_nodes():
	panel_event = get_node("hsplit/left_panel/Event")
	panel_actor = get_node("hsplit/left_panel/Actor")
	panel_event_detail = get_node("hsplit/panel_event_detail")

func save_to_file():
	await get_tree().create_timer(0.3).timeout
	
	get_nodes()
	res_data.res_actors = panel_actor.get_res_as_array()
	res_data.res_events = panel_event.get_res_as_array()
	ResourceSaver.save(res_data, SAVEPATH)
	
func load_from_file():
	get_nodes()
	if ResourceLoader.exists(SAVEPATH):
		res_data = load(SAVEPATH) as Res_Event_System
		panel_actor.restore_data(res_data.res_actors)
		panel_event.restore_data(res_data.res_events)
	else:
		res_data = Res_Event_System.new()
		
	
