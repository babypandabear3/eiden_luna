extends PanelContainer

@onready var lbl_fps : Label = $vbox/HBoxContainer/lbl_fps
@onready var lbl_count : Label = $vbox/HBoxContainer2/lbl_count

@onready var ai_body := preload("res://tmp/ai_body.tscn")
var ai_body_count := 0

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	lbl_fps.text = str( Engine.get_frames_per_second() )
	return
	
func instance_random_npc(): #THIS METHOD SHOULD BE DELETED LATER ON
	if Input.is_action_just_pressed("ui_accept"):
		ai_body_count += 10
		for o in range(10):
			var obj = ai_body.instantiate()
			var pos = Vector3.ZERO
			pos.x = randf_range(-40.0, 40.0)
			pos.z = randf_range(-40.0, 40.0)
			pos.y = 2.0
			obj.position = pos
			get_parent().add_child(obj)
			lbl_count.text = str(ai_body_count)
