@tool
extends Node3D

@export var idle_animation : String = "IDLE"
@export var run_animation : String = "RUN"
@export var jump_animation : String = "JUMP"

@onready var body = get_parent()
@onready var model = get_child(0)
var animplayer : AnimationPlayer

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not body.editor_walker_active:
		if animplayer:
			if animplayer.is_playing():
				animplayer.stop()
		return
		
	if not animplayer:
		find_animplayer()
		return
	
	if body.is_on_floor():
		if body.velocity.length() < 0.1:
			if animplayer.current_animation != idle_animation:
				animplayer.play(idle_animation)
		else:
			if animplayer.current_animation != run_animation:
				animplayer.play(run_animation)
		
	else:
		if animplayer.current_animation != jump_animation:
			animplayer.play(jump_animation)
			
	
	var bas_a = global_transform.basis
	var bas_b = global_transform.basis
	bas_b.z = -body.last_major_direction
	bas_b.x = bas_b.y.cross(bas_b.z)
	global_transform.basis = bas_a.slerp(bas_b, 10.0 * delta)
	
	

func find_animplayer():
	for o1 in get_children():
		for o2 in o1.get_children():
			if o2 is AnimationPlayer:
				animplayer = o2
				animplayer.playback_default_blend_time = 0.1
		
