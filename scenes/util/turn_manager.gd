extends Node

signal turn_started(player_index: int)
signal turn_ended(player_index: int)

var player_count = 2
var current_player: int = 0

var unit_groups := {} # {0: [unit1, unit2], 1: [unit3, unit4]}

func _ready():
	print("TurnManager ready. Starting with Player 0.")
	start_turn()

func start_turn():
	print("Player %d's turn starts" % current_player)
	emit_signal("turn_started", current_player)
	reset_units()

func end_turn():
	print("Player %d's turn ends" % current_player)
	emit_signal("turn_ended", current_player)

	# Advance to next player
	current_player = (current_player + 1) % player_count
	start_turn()

func register_unit(unit: Node, player_owner: int):
	if unit_groups.has(player_owner):
		unit_groups[player_owner].append(unit)
	else:
		unit_groups[player_owner] = [unit]

func unregister_unit(unit: Node, player_owner: int):
	if unit_groups.has(player_owner):
		if unit in unit_groups[player_owner]:
			unit_groups[player_owner].erase(unit)

func reset_units():
	for player in unit_groups.values():
		for unit in player:
			unit.moved = false
			unit.attacked = false
			unit.done = false
			unit.set_color()
			
func connect_action_menu(menu: Node):
	if not menu.is_connected("end_turn_selected", Callable(self, "_on_end_turn_selected")):
		menu.connect("end_turn_selected", Callable(self, "_on_end_turn_selected"))
		
func _on_end_turn_selected() -> void:
	TurnManager.end_turn()
