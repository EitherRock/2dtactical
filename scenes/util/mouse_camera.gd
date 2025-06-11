extends Camera2D

var zoom_step := 0.1
var min_zoom := 1.15
var max_zoom := 3.0

@onready var map = $"../GridMap"
@onready var cursor = $Cursor

var middle_mouse_held := false
#var drag_target := Vector2.ZERO
#var drag_speed := 10.0

var last_mouse_pos := Vector2.ZERO

func _ready() -> void:
	var map_pixel_width = map.map_size.x * Util.tile_size.x
	var map_pixel_height = map.map_size.y * Util.tile_size.y
	
	limit_left = 0
	limit_top = 0
	limit_right = map_pixel_width
	limit_bottom = map_pixel_height
	
	#drag_target = global_position
	
	
func _process(_delta: float) -> void:
	#var target_pos = get_global_mouse_position()
	#cursor.global_position = target_pos
	##global_position = global_position.lerp(target_pos, 0.1)
	
	# Smooth camera movement toward drag_target
	#global_position = global_position.lerp(drag_target, drag_speed * delta)
	
	# Always update cursor
	cursor.global_position = get_global_mouse_position()



func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			middle_mouse_held = event.pressed
			last_mouse_pos = get_viewport().get_mouse_position()


		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_step)
	
	elif event is InputEventMouseMotion and middle_mouse_held:
		#drag_target += event.relative
		var current_pos = get_viewport().get_mouse_position()
		var delta = last_mouse_pos - current_pos
		global_position += delta
		last_mouse_pos = current_pos


func zoom_camera(amount: float):
	var new_zoom = zoom + Vector2(amount, amount)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
