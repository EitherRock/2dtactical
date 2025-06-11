extends Node2D

@onready var map = $GridMap
@onready var units = $Units
@onready var mouse_camera = $MouseCamera
@onready var action_menu = $CanvasLayer/ActionMenu
@onready var combat_window = $CombatWindow

var selected_unit = null
var attack_mode = false

func _ready():
	for color in units.get_children():
		for unit in color.get_children():
			unit.connect("unit_selected", Callable(self, "_on_unit_selected"))
			unit.connect("unit_moved", Callable(self, "_on_unit_moved"))
	
	TurnManager.connect_action_menu(action_menu)
	action_menu.connect("unit_attack", Callable(self, "_on_attack_selected"))
	if not action_menu.is_connected("unit_wait", _on_waiting):
		action_menu.connect("unit_wait", Callable(self, "_on_waiting"))
		
	#combat_window.visible = false


func _input(event):
	if attack_mode:
		handle_attack_input(event)
	elif selected_unit:
		handle_movement_input(event)
	else:
		handle_general_input(event)

func handle_attack_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var target_tile = map.ground_layer.local_to_map(get_global_mouse_position())
		var target_unit = get_unit_on_tile(target_tile)

		if target_unit and selected_unit and target_unit.player_owner != selected_unit.player_owner:
			selected_unit.attack(target_unit)
			#combat_window.set_sides()
			combat_window.show_combat(selected_unit, target_unit)
			clear_unit()
		else:
			print("Invalid attack target or no unit.")
		attack_mode = false


func handle_movement_input(event):
	if event is InputEventMouseMotion and !selected_unit.moved and TurnManager.current_player == selected_unit.player_owner:
		show_arrow_path(selected_unit)
	elif selected_unit.destination and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selected_unit.move_unit()
		map.path_to_draw = null
		map.clear_path_decorations()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		clear_unit()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		quit_game()


func handle_general_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		show_action_menu()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		quit_game()
		
		
func _on_unit_selected(unit):
	if unit in TurnManager.unit_groups[TurnManager.current_player] and !unit.done:
		
		# update the z_index of current selected_unit before assigning a new unit as selected_unit
		if selected_unit:
			selected_unit.z_index = 0
		
		# If the selected unit is clicked on again during its move phase, then it will stay in place.
		if selected_unit == unit:
			selected_unit.destination = selected_unit.previous_location
			selected_unit.move_unit()
			map.path_to_draw = null
			map.clear_path_decorations()
		else:
			# Assign new selected_unit
			selected_unit = unit
			print('selected unit: ', selected_unit)
		
func _on_unit_moved(_unit):
	show_action_menu()
		
func quit_game():
	get_tree().quit()
	
func clear_unit():
	print('unselected unt: ', selected_unit)
	selected_unit.destination = null
	selected_unit = null
	map.path_line.clear_points()
	map.clear_path_decorations()
	
func show_action_menu():
	var clicked_tile = map.ground_layer.local_to_map(get_global_mouse_position())
	var local_pos = get_viewport().get_mouse_position()

	if is_tile_occupied(clicked_tile, true) and selected_unit:
		action_menu.set_actions(action_menu.unit_actions)
	else:
		action_menu.set_actions(action_menu.player_actions)

	action_menu.position = local_pos
	action_menu.popup()
	action_menu.set_focused_item(0)


func is_tile_occupied(tile_pos: Vector2i, is_canvas: bool) -> bool:
	if not is_canvas:
		tile_pos = map.ground_layer.local_to_map(Vector2(tile_pos))
		
	for color in units.get_children():
		for unit in color.get_children():
			var unit_tile = map.ground_layer.local_to_map(unit.global_position)
			if unit_tile == tile_pos:
				return true
	return false
	
	
func show_arrow_path(selected_unit):
	var mouse_tile_pos = map.ground_layer.local_to_map(get_global_mouse_position())
	var unit_tile_pos = map.ground_layer.local_to_map(selected_unit.global_position)

	if map.astar.is_in_bounds(unit_tile_pos.x, unit_tile_pos.y) and map.astar.is_in_bounds(mouse_tile_pos.x, mouse_tile_pos.y):
		if not map.astar.is_point_solid(mouse_tile_pos):
			var path = map.astar.get_point_path(unit_tile_pos, mouse_tile_pos)
			
			if path.size() > 0:
				# Only draw path up to selected units movement range
				map.path_to_draw = path.slice(0, min(selected_unit.move_range + 1, path.size()))
				selected_unit.previous_location = map.path_to_draw[0]
				if not is_tile_occupied(map.path_to_draw[-1], false):
					selected_unit.destination = map.path_to_draw[-1]
				else:
					selected_unit.destination = null
				map.draw_path(map.path_to_draw)
				

func _on_waiting():
	if selected_unit:
		selected_unit.unit_done()
		selected_unit.z_index = 0 # Set the display order back to zero
		selected_unit = null
	
func _on_attack_selected():
	attack_mode = true
	
func get_unit_on_tile(tile_pos: Vector2i) -> Unit:
	for color in units.get_children():
		for unit in color.get_children():
			var unit_tile = map.ground_layer.local_to_map(unit.global_position)
			if unit_tile == tile_pos:
				return unit
	return null
