extends Node2D
var unit_name
var unit_color
var unit_position
var map

var unit_selected
var unit_movement_range = 1
var health
var damage
var attack_range
var moved = false
var player

var x_max
var y_max

func _ready():
	map = get_parent().get_parent().get_parent()
	load_unit_animations()
	
	x_max = GameData.map_width
	y_max = GameData.map_height
	
	if unit_color == "red": 
		player = "computer"
	elif unit_color == "blue": 
		player = "player"
	else: player = "neutral"
	
	match unit_name:
		"warrior": 
			unit_movement_range = 2
			health              = 7
			damage              = 3
			attack_range        = 1
			
		"archer": 
			unit_movement_range = 2
			health              = 6
			damage              = 4
			attack_range        = 3
		
		"cavalry_warrior": 
			unit_movement_range = 3
			health              = 15
			damage              = 5
			attack_range        = 1
	
func get_unit_possible_moves():
	var possible_squares = []
	if moved == false:
		for x in range(unit_position[0] - unit_movement_range, unit_position[0] + unit_movement_range+1):
			for y in range(unit_position[1] - unit_movement_range, unit_position[1] + unit_movement_range+1):
				possible_squares.append([x,y])
	return validate_possible_moves(possible_squares)

func validate_possible_moves(moves):
	var validated_moves = []
	#var in_bounds = false
	#var empty_square = false
	for move in moves:
		
		if (move[0] < x_max && move[0] > -1) && (move[1] < y_max && move[1] > -1):
			if !(map.get_square(move[0], move[1]).has_unit() || map.get_square(move[0], move[1]).has_building()):
				validated_moves.append(move)
	
	return validated_moves
	
func move(x_coord, y_coord):
	var new_square = map.get_square(x_coord, y_coord)
	reparent(new_square, false)
	unit_position = [x_coord, y_coord]
	moved = true

func load_unit_animations():
	var animated_sprite = load("res://levels/prefabs/animations/"+unit_color+"_"+unit_name+".tscn")
	var instance = animated_sprite.instantiate()
	add_child(instance)

#func place_unit():
	#position.x = unit_position[0]*64 + GameData.starting_square_position[0]
	#position.y = unit_position[1]*64 + GameData.starting_square_position[1]
	#pass
# Called every frame. 'delta' is the elapsed time since the previous frame.

