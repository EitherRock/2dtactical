extends Node

var tile_size = Vector2i(16,16)

func center_of_tile(tile_position):
	return Vector2i(tile_position) + tile_size / 2
