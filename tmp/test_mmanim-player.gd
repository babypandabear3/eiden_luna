@tool
extends Node3D

@export var play : bool = false :
	set(value):
		play = false
		play_anim()
		
@export var request_animation : bool = false :
	set(value):
		request_animation = false
		request_anim()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.active = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func play_anim():
	var mma : MMAnimationPlayer = $MMAnimationPlayer
	var anim = mma.current_animation
	mma.play(anim)

func request_anim():
	var mma : MMAnimationPlayer = $MMAnimationPlayer
	var anim = mma.current_animation
	mma.request_animation("RUN", 0.1)
