extends Area2D
class_name Unit

signal unit_selected(unit)
signal unit_moved(unit)

@onready var sprite = $Sprite2D

@export var unit_type := 'infantry'
@export var move_range := 5
@export var max_health := 5
@export var current_health := 5
@export var attack_power := 2
@export var defense := 1

@export var done_sprite = preload("res://graphics/Tiles/tile_0106.png")

var destination = null
var previous_location = null
var moved = false
var attacked = false
var done = false
var player_owner = null


func _ready():
	set_color()
	TurnManager.register_unit(self, player_owner)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if TurnManager.current_player == player_owner:
			z_index = 5  # random number so the selected unit is shown above other sprites
			emit_signal("unit_selected", self)


func move_unit():
	if TurnManager.current_player != player_owner:
		return
		
	if !destination:
		destination = previous_location
		
	global_position = Util.center_of_tile(destination)
	previous_location = destination
	destination = null
	moved = true
	emit_signal('unit_moved', self)

func unit_done():
	sprite.texture = done_sprite
	done = true
	
func set_color():
	var color_name = get_parent().name.to_lower()
	
	if color_name in Globals.color_sprites:
		var unit_texture = Globals.color_sprites[color_name]['units'].get(unit_type, null)
		if unit_texture:
			sprite.texture = load(unit_texture)
	
	# Set player owner to blue or orange
	player_owner = {
		'blue': 0,
		'orange': 1
	}.get(color_name, null)
		
func take_damage(amount: int, attacker: Unit = null):
	var damage = clamp(amount - defense, 1, amount)
	current_health -= damage
	print("%s took %d damage. Remaining: %d" % [unit_type, damage, current_health])
	
	if current_health > 0 and attacker:
		attack(attacker)
	#elif current_health <= 0:
		#die()

func die():
	queue_free()
	TurnManager.unregister_unit(self, player_owner)
	
func attack(target: Unit):
	if attacked or done:
		return
	
	print("%s attacks %s" % [unit_type, target.unit_type])
	target.take_damage(attack_power)
	attacked = true
	unit_done()
	
	
	
	
