extends Area2D

signal unit_selected(unit)

var move_range = 5

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("unit_selected", self)
