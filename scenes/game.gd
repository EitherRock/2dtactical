extends Node2D

@onready var map = $GridMap
@onready var units = $Units
@onready var mouse_camera = $MouseCamera

var selected_unit = null


func _ready():
	print(map.ground_layer)
	for unit in units.get_children():
		unit.connect("unit_selected", Callable(self, "_on_unit_selected"))
		

func _process(_delta):
	var target_pos = get_global_mouse_position()
	mouse_camera.global_position = mouse_camera.global_position.lerp(target_pos, 0.1) # 0.1 = smoothing factor
	


func _input(event):
	if event is InputEventMouseMotion and selected_unit:
		var mouse_tile_pos = map.ground_layer.local_to_map(get_global_mouse_position())
		var unit_tile_pos = map.ground_layer.local_to_map(selected_unit.global_position)

		if map.astar.is_in_bounds(unit_tile_pos.x, unit_tile_pos.y) and map.astar.is_in_bounds(mouse_tile_pos.x, mouse_tile_pos.y):
			if not map.astar.is_point_solid(mouse_tile_pos):
				var path = map.astar.get_point_path(unit_tile_pos, mouse_tile_pos)
				
				if path.size() > 0:
					var path_range = path.slice(0, min(selected_unit.move_range + 1, path.size()))
					map.draw_path(path_range)
				
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		selected_unit = null
		map.path_line.clear_points()
		map.clear_path_decorations()
		
func _on_unit_selected(unit):
	selected_unit = unit
