extends Control

@onready var lbl_fps = $VBoxContainer/HBoxContainer/lbl_fps
@onready var printer_root = $VBoxContainer/Printer_root
var printer = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for o in printer_root.get_children():
		printer.append(o)
		o.text = ""

func _process(_delta):
	lbl_fps.text = str( Engine.get_frames_per_second() )
	
func _print(_text):
	for i in printer.size()-1:
		var idx = printer.size() - i - 1
		printer[idx].text = printer[idx-1].text
	printer[0].text = str(_text)
	
