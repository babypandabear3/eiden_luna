@tool
extends VBoxContainer

var le_actor : LineEdit
var actor_container : VBoxContainer
var res : Res_Actor
var row_actor_i : PackedScene

func _ready():
	pass # Replace with function body.

func get_nodes():
	le_actor = $HBoxContainer/le_actor as LineEdit
	actor_container = $ScrollContainer/actor_container as VBoxContainer
	row_actor_i = load("res://addons/bpb_event_editor/actor_row.tscn")
	
func fix_size():
	await get_tree().process_frame
	get_child(0).size = size


func _on_btn_clear_button_down():
	get_nodes()
	le_actor.text = ""
	le_actor.grab_focus()


func _on_le_actor_text_submitted(new_text):
	save_new()


func _on_btn_save_button_down():
	save_new()
	
func save_new():
	get_nodes()
	var row = row_actor_i.instantiate()
	actor_container.add_child(row)
	
	res = Res_Actor.new()
	res.actor = le_actor.text
	row.set_data(res)
	
	refresh_id()
	
func refresh_id():
	get_nodes()
	for i in actor_container.get_child_count():
		var row = actor_container.get_child(i)
		row.set_id(i)

func get_res_as_array():
	get_nodes()
	var ret = []
	for row in actor_container.get_children():
		ret.append(row.res_data)
	return ret

func restore_data(_res):
	get_nodes()
	for row in actor_container.get_children():
		row.queue_free()
	await get_tree().process_frame
	for r in _res:
		var row = row_actor_i.instantiate()
		actor_container.add_child(row)
		row.set_data(r)
