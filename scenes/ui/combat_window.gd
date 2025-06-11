extends CanvasLayer

@onready var panel = $Panel
@onready var attacking = $Panel/HBoxContainer/Attacking
@onready var defending = $Panel/HBoxContainer/Defending


func show_combat(attacking_unit: Unit, defending_unit: Unit):
	var attacking_color = attacking_unit.get_parent().name.to_lower()
	var attacking_type = attacking_unit.unit_type
	
	var defending_color = defending_unit.get_parent().name.to_lower()
	var defending_type = defending_unit.unit_type
	
	attacking.texture = load(Globals.color_sprites[attacking_color]['units'].get(attacking_type, null))
	defending.texture = load(Globals.color_sprites[defending_color]['units'].get(defending_type, null))
	
	get_tree().paused = true
	panel.visible = true
	
	print('timer start')
	await get_tree().create_timer(2.0).timeout
	
	if defending_unit.current_health <= 0:
		defending.visible = false
		defending_unit.die()
	
	await get_tree().create_timer(1.0).timeout
		
	print('timer stop')
	panel.visible = false
	get_tree().paused = false
	
	
	
