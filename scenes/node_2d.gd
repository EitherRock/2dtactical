extends Node2D

@export var grid_size: Vector2 = Vector2(16, 16)
@export var grid_color: Color = Color(0.4, 0.4, 0.4, 0.5)

func _draw():
	var screen_size = get_viewport_rect().size
	for x in range(0, int(screen_size.x), int(grid_size.x)):
		draw_line(Vector2(x, 0), Vector2(x, screen_size.y), grid_color)

	for y in range(0, int(screen_size.y), int(grid_size.y)):
		draw_line(Vector2(0, y), Vector2(screen_size.x, y), grid_color)

func _process(_delta):
	queue_redraw()
