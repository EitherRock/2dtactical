extends CanvasLayer

#@onready var panel = $Panel
@onready var panel = $Panel2
#@onready var attacking = $Panel/HBoxContainer/AttackerContainer/Attacking
#@onready var defending = $Panel/HBoxContainer/DefenderContainer/Defending
@onready var attacking_hp_bar= $Panel2/HBoxContainer/AttackerDisplay/ProgressBar
@onready var defending_hp_bar = $Panel2/HBoxContainer/DefenderDisplay/ProgressBar2
@onready var control_attacking = $Panel2/HBoxContainer/AttackerDisplay/Control
@onready var control_defending = $Panel2/HBoxContainer/DefenderDisplay/Control2

	

func show_combat(attacking_unit: Unit, defending_unit: Unit):
	setup_unit_display($Panel2/HBoxContainer/AttackerDisplay, attacking_unit, control_attacking)
	attacking_hp_bar.value = attacking_unit.current_health
	
	setup_unit_display($Panel2/HBoxContainer/DefenderDisplay, defending_unit, control_defending)
	defending_hp_bar.value = defending_unit.current_health
	
	get_tree().paused = true
	panel.visible = true
	#defending.visible = true
	defending_hp_bar.visible = true
	#attacking.visible = true
	attacking_hp_bar.visible = true
	
	attacking_unit.attack(defending_unit)
	

	#Update health bars after combat
	
	await get_tree().create_timer(1.0).timeout
	defending_hp_bar.value = defending_unit.current_health
	update_unit_icons(control_defending, defending_unit)
	
	if defending_unit.current_health <= 0:
		#defending.visible = false
		#defending_hp_bar.visible = false
		defending_unit.die()
		panel.visible = false
		get_tree().paused = false
		return
	
	await get_tree().create_timer(1.0).timeout
	attacking_hp_bar.value = attacking_unit.current_health
	update_unit_icons(control_attacking, attacking_unit)
	
	if attacking_unit.current_health <= 0:
		#attacking.visible = false
		#attacking_hp_bar.visible = false
		attacking_unit.die()
		panel.visible = false
		get_tree().paused = false
		return
	
	await get_tree().create_timer(1.0).timeout
	
	panel.visible = false
	get_tree().paused = false
		
	

	
func setup_unit_display(_display: FlowContainer, unit: Unit, control: Control) -> void:
	var unit_color = unit.get_parent().name.to_lower()
	var unit_type_str = Globals.UNIT_TYPE_NAMES[unit.unit_type]
	var unit_type = unit.unit_type
	
	var max_units := control.get_child_count()
	var hp_missing := unit.max_health - unit.current_health
	var units_to_remove := hp_missing / 2
	
	
	# Loop through each child and decide whether to show or hide
	for i in range(max_units):
		var child := control.get_child(i)
		if child is TextureRect:
			child.texture = load(Globals.color_sprites[unit_color]['units'].get(unit_type_str, null))
			child.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			child.custom_minimum_size = Vector2(16, 16)

			# Hide this icon if it's part of the ones being "removed"
			child.visible = i < (max_units - units_to_remove)
			

func update_unit_icons(control: Control, unit: Unit) -> void:
	var max_icons := control.get_child_count()
	var hp_missing := unit.max_health - unit.current_health
	var icons_to_remove := hp_missing / 2

	for i in range(max_icons):
		var child := control.get_child(i)
		if child is TextureRect:
			child.visible = i < (max_icons - icons_to_remove)

	
	
