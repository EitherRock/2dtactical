extends PopupMenu

signal end_turn_selected
signal unit_wait
signal unit_attack

var unit_actions = {
	'attack': {'name': 'Attack', 'index': 0, 'signal': 'unit_attack'},
	'wait': {'name': 'Wait', 'index': 1, 'signal': 'unit_wait'}
}

var player_actions = {
	'end_turn': {'name': 'End Turn', 'index': 0, 'signal': 'end_turn_selected'}
}

var current_actions = {}

func _ready() -> void:
	clear()
	visible = false
	connect("id_pressed", Callable(self, "_on_id_pressed"))


func _on_id_pressed(id):	
	for action in current_actions.values():
		if action.index == id:
			print('emitting signal', action.signal)
			emit_signal(action.signal)
			break


func set_actions(actions):
	if current_actions != actions:
		clear()
		current_actions = actions
		for action in actions.values():
			add_item(action.name, action.index)
		
