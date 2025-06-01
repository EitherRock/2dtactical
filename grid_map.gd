extends Node2D

@onready var ground_layer = $Ground
@onready var path_line = $PathLine
@onready var path_decorations = $PathDecorations
@onready var cursor = $Cursor

var astar = AStarGrid2D.new()
var tile_size = Vector2i(16,16)
var map_size = null


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	#var cursor_texture = preload("res://graphics/Tiles/tile_0061.png")
	#Input.set_custom_mouse_cursor(cursor_texture, 0, Vector2(16, 16))
	var map_used_rect: Rect2i = ground_layer.get_used_rect()
	map_size = map_used_rect.size
	setup_astar_grid(map_size)

		
func _process(_delta):
	cursor.global_position = get_global_mouse_position()

func setup_astar_grid(map_size):
	astar.region = Rect2i(Vector2i.ZERO, map_size)
	astar.cell_size = tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar.update()
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var pos = Vector2i(x,y)
			var solid = ground_layer.get_cell_source_id(pos) == -1
			astar.set_point_solid(pos, solid)

	astar.update()


		
func draw_path(path: Array[Vector2i]) -> void:
	path_line.clear_points()
	clear_path_decorations()
	
	for tile_pos in path:
		var centered_pos = tile_pos + tile_size / 2
		path_line.add_point(centered_pos)

	# Add arrow sprite at the last segment
	if path.size() >= 2:
		var points_len = path_line.points.size()
		
		for i in range(points_len):
			var current_pos = path_line.points[i]
			
			if i > 0  and i < points_len - 1:
				var previous_pos = path_line.points[i - 1]
				var next_pos = path_line.points[i + 1]
				
				var dir_from = (current_pos - previous_pos).normalized()
				var dir_to = (next_pos - current_pos).normalized()
				
				if dir_from != dir_to:
					var corner_sprite = Sprite2D.new()
					corner_sprite.texture = preload("res://graphics/Tiles/tile_0059.png")
					path_decorations.add_child(corner_sprite)
					corner_sprite.position = current_pos
					
					# Determine correct rotation for corner based on turn direction
					var rotation_lookup = {
						# Format: [dir_from, dir_to]: rotation (in degrees)
						[Vector2.LEFT, Vector2.UP]: 0,
						[Vector2.DOWN, Vector2.RIGHT]: 0,

						[Vector2.UP, Vector2.RIGHT]: 90,
						[Vector2.LEFT, Vector2.DOWN]: 90, 

						[Vector2.RIGHT, Vector2.DOWN]: 180,
						[Vector2.UP, Vector2.LEFT]: 180,

						[Vector2.DOWN, Vector2.LEFT]: 270,
						[Vector2.RIGHT, Vector2.UP]: 270,
					}

					# Get rotation from lookup
					var rot = rotation_lookup.get([dir_from, dir_to], 0)
					corner_sprite.rotation_degrees = rot - 90
				
				else:
					var line_sprite = Sprite2D.new()
					line_sprite.texture = preload("res://graphics/Tiles/tile_0058.png")
					path_decorations.add_child(line_sprite)
					line_sprite.position = current_pos
					
					var direction = (current_pos - previous_pos).normalized()
					line_sprite.rotation = direction.angle() + deg_to_rad(90)
			
		var arrow_sprite = Sprite2D.new()
		#arrow_sprite.name = "ArrowSprite"
		arrow_sprite.texture = preload("res://graphics/Tiles/tile_0043.png")
		path_decorations.add_child(arrow_sprite)

		var last_pos = path_line.points[-1]
		var second_last_pos = path_line.points[-2]
		arrow_sprite.position = last_pos

		# Calculate angle of the last segment for rotation
		var direction = (last_pos - second_last_pos).normalized()
		arrow_sprite.rotation = direction.angle()
		
func clear_path_decorations():
	for child in path_decorations.get_children():
		child.queue_free()

		
