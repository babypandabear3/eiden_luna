extends Node

@export var cloud_cutoff : NoiseTexture2D
@export var cloud_weight : NoiseTexture2D
# Called when the node enters the scene tree for the first time.
var cloud_cutoff_img
var cloud_weight_img

var sky
var time := 0.0
var time_scale := 0.5
var x := 0
var y := 0

var max_x := 512
var max_y := 512

func _ready():
	call_deferred("late_ready")
	
func late_ready():
	sky = get_parent()
	cloud_cutoff_img = cloud_cutoff.noise.get_image(512,512)
	cloud_weight_img = cloud_weight.noise.get_image(512,512)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * time_scale
	x = floori(time)
	if floori(time) == max_x:
		y += 1
		if y == max_y:
			y = 0
		x = 0
	update_cloud_cutoff()
	update_cloud_weight()

func update_cloud_cutoff():
	var height = get_height_from_img(cloud_cutoff_img, x, y) / 512
	height = height * 0.5
	if sky.clouds_cutoff != height:
		var from = sky.clouds_cutoff
		var to = height
		var tween = create_tween()
		tween.tween_method(Callable(self, "interpolate_cloud_cutoff").bind(from, to), 0.0, 1.0, 1.0)

	
func interpolate_cloud_cutoff(weight, from, to):
	sky.clouds_cutoff = lerpf(from, to, weight)
	
	
func update_cloud_weight():
	var height = get_height_from_img(cloud_weight_img, x, y) / 512
	if sky.clouds_weight != height:
		var from = sky.clouds_weight
		var to = height
		var tween = create_tween()
		tween.tween_method(Callable(self, "interpolate_cloud_weight").bind(from, to), 0.0, 1.0, 1.0)

	
func interpolate_cloud_weight(weight, from, to):
	sky.clouds_weight = lerpf(from, to, weight)
	
func get_height_from_img(height_img, x, y):
	var ret = height_img.get_pixel(
		int(fposmod(x, 512)),
		int(fposmod(y, 512))
		).r * 512
	return ret
