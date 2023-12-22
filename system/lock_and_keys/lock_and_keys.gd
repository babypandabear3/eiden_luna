@tool
class_name  Lock_and_Keys
extends Node

@export var unique_id : String

@export var new_door_automatic : bool = false :
	set(_value):
		_new_door_automatic()
		new_door_automatic = false

@export var new_door_keycard : bool = false :
	set(_value):
		_new_door_keycard()
		new_door_keycard = false
				
@export var new_door_require_key : bool = false :
	set(_value):
		_new_door_require_key()
		new_door_require_key = false
		
@export var new_key : bool = false :
	set(_value):
		_new_key()
		new_key = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _new_door_automatic():
	print("new door automatic")
	var door = load("res://system/lock_and_keys/door_automatic.tscn").instantiate()
	var tmp_name = door.name
	add_child(door)
	door.owner = owner
	door.name = tmp_name
	
func _new_door_keycard():
	print("new door automatic")
	var door = load("res://system/lock_and_keys/door_keycard.tscn").instantiate()
	var tmp_name = door.name
	add_child(door)
	door.owner = owner
	door.name = tmp_name
	
func _new_door_require_key():
	print("new door require key")
	var door = load("res://system/lock_and_keys/door_require_key.tscn").instantiate()
	var tmp_name = door.name
	add_child(door)
	door.owner = owner
	door.name = tmp_name

func _new_key():
	print("create new key")
	pass

