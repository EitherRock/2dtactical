extends Camera2D

var zoom_step := 0.1
var min_zoom := 0.5
var max_zoom := 3.0

@onready var map = $"../GridMap"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map_pixel_width = map.map_size.x * map.tile_size.x
	var map_pixel_height = map.map_size.y * map.tile_size.y
	
	limit_left = 0
	limit_top = 0
	limit_right = map_pixel_width
	limit_bottom = map_pixel_height
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_step)
			

func zoom_camera(amount: float):
	var new_zoom = zoom + Vector2(amount, amount)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
