extends Node2D
var unit_name
var unit_color
var unit_position
var map

var unit_selected
var unit_movement_range = 1
var health
var attack_range
var moved = false

func _ready():
	map = get_parent().get_parent().get_parent()

func get_unit_possible_moves():
	var possible_squares = []
	if moved == false:
		for x in range(unit_position[0] - unit_movement_range, unit_position[0] + unit_movement_range+1):
			for y in range(unit_position[1] - unit_movement_range, unit_position[1] + unit_movement_range+1):
				possible_squares.append([x,y])
	return possible_squares
	
func move(x_coord, y_coord):
	var new_square = map.get_square(x_coord, y_coord)
	reparent(new_square, false)
	unit_position = [x_coord, y_coord]
	moved = true

#func place_unit():
	#position.x = unit_position[0]*64 + GameData.starting_square_position[0]
	#position.y = unit_position[1]*64 + GameData.starting_square_position[1]
	#pass
# Called every frame. 'delta' is the elapsed time since the previous frame.

