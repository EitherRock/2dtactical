extends Node2D

@onready var ground_layer = $Ground
@onready var tree_layer = $Trees

@onready var path_line = $PathLine
@onready var path_decorations = $PathDecorations

var astar = AStarGrid2D.new()
var tree_positions := {}
var map_size = null
var path_to_draw = null


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	var map_used_rect: Rect2i = ground_layer.get_used_rect()
	map_size = map_used_rect.size
	setup_astar_grid(map_size)


func setup_astar_grid(size_of_map):
	astar.region = Rect2i(Vector2i.ZERO, size_of_map)
	#astar.cell_size = tile_size
	astar.cell_size = Util.tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar.update()
	
	for x in range(size_of_map.x):
		for y in range(size_of_map.y):
			var pos = Vector2i(x,y)
			
			# Solid check
			var solid = ground_layer.get_cell_source_id(pos) == -1
			astar.set_point_solid(pos, solid)
			
			
			# Tree tile check
			# TODO set point weight scale for movement
			var tree_tile_data = tree_layer.get_cell_tile_data(pos)
			if tree_tile_data:
				var atlas_coords = tree_layer.get_cell_atlas_coords(pos)
				var source_id = tree_layer.get_cell_source_id(pos)
				tree_positions[pos] = {
					'atlas_coords': atlas_coords,
					'source_id': source_id
				}

	astar.update()


func draw_path(path: Array[Vector2i]) -> void:
	path_line.clear_points()
	clear_path_decorations()
	
	for tile_pos in path:
		#var centered_pos = tile_pos + Util.tile_size / 2
		var centered_pos = Util.center_of_tile(tile_pos)
		
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
					corner_sprite.z_index = 4
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
					line_sprite.z_index = 4
					path_decorations.add_child(line_sprite)
					line_sprite.position = current_pos
					
					var line_direction = (current_pos - previous_pos).normalized()
					line_sprite.rotation = line_direction.angle() + deg_to_rad(90)
			
		var arrow_sprite = Sprite2D.new()
		arrow_sprite.texture = preload("res://graphics/Tiles/tile_0043.png")
		arrow_sprite.z_index = 4
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
		

func is_tree_tile(pos: Vector2i) -> bool:
	var local_pos = tree_layer.local_to_map(Vector2(pos))
	#return pos in tree_positions
	return local_pos in tree_positions

func get_tree_metadata(pos: Vector2i) -> Dictionary:
	if not tree_positions.has(pos):
		return {}
	var info = tree_positions[pos]
	return tree_layer.tile_set.get_custom_data(info.source_id, info.atlas_coords)


		
