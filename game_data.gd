extends Node

var selected_square
var starting_square_position
var selected_unit

var map_width
var map_height

var player_turn = 1
var squares

func calculate_minimap(squares):
	var minimap = []
	for square in squares:
		minimap.append(square.get_player())

	
	return minimap
