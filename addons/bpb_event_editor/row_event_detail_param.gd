@tool
extends HBoxContainer

signal event_detail_param_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_le_key_text_changed(new_text):
	emit_signal("event_detail_param_updated")


func _on_le_value_text_changed(new_text):
	emit_signal("event_detail_param_updated")

func get_key():
	return $le_key.text
	
func get_value():
	return $le_value.text

func set_key(par):
	$le_key.text = par
	
func set_value(par):
	$le_value.text = par
