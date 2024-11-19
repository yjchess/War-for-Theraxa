extends Node2D
var ability_name = "summon_skeleton"
var cooldown = 1
var cooldown_progress = 1
var ability_range = 2
var type_viable = "empty"
@onready var unit = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():

	match ability_name: 
		"summon_skeleton":
			cooldown = 1
			cooldown_progress = 1
			ability_range = 2
			type_viable = "empty"

	name = ability_name
	
func viable_squares():
	var empty_squares = []
	var enemy_squares = []
	var ally_squares = []
	
	var x_one = unit.unit_position[0] - ability_range
	var x_two = unit.unit_position[0] + ability_range
	var y_one = unit.unit_position[1] - ability_range
	var y_two = unit.unit_position[1] + ability_range
	
	var squares = GameData.get_squares(x_one, x_two, y_one, y_two)
	for square in squares:
		if square.has_unit() || square.has_building():
			if square.has_enemy_unit(unit.unit_color) || square.has_enemy_building(unit.unit_color):
				enemy_squares.append([square.x_coord, square.y_coord])
			else:
				ally_squares.append([square.x_coord, square.y_coord])
		else:
			empty_squares.append([square.x_coord, square.y_coord])
	
	match type_viable:
		"enemy": return enemy_squares
		"empty": return empty_squares
		"ally" : return ally_squares

func has_viable_placements():
	if len(viable_squares()) > 0 && cooldown_progress == cooldown:
		return true
	else:
		return false

func summon_skeleton(color, square_location):
	#print("SUMMONING SKELETON")
	if cooldown_progress == cooldown:
		GameData.map.place_piece(color, "skeleton", square_location, 3)
		cooldown_progress = 0

func check_cooldown():
	return cooldown - cooldown_progress

func increment_cooldown():
	cooldown_progress += 0.5
	if cooldown_progress > cooldown:
		cooldown_progress = cooldown		
