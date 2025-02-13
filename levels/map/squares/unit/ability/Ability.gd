extends Node2D

class_name Ability
var ability_name = "summon_skeleton"
var cooldown = 1
var cooldown_progress = 1
var ability_range = 2
var type_viable = ["empty"]
var viable_squares = []
signal determine_viable
signal summon_unit
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

func determine_viable_squares():
	var bound_one = [unit.unit_position[0] - ability_range, unit.unit_position[1] - ability_range]
	var bound_two = [unit.unit_position[0] + ability_range, unit.unit_position[1] + ability_range]
	var bounds =[]
	
	for x in range(bound_one[0], bound_two[0]):
		for y in range(bound_one[1], bound_two[1]):
			bounds.append([x,y])
	#propagated through to unit --> map --> level
	emit_signal("determine_viable", type_viable, self, bounds)
	

func has_viable_placements():
	if len(viable_squares) > 0 && cooldown_progress == cooldown: return true
	else: return false

func summon_skeleton(color, square_location):
	#print("SUMMONING SKELETON")
	if cooldown_progress == cooldown:
		#propagated through to unit --> map --> level
		emit_signal("summon_unit", color, "skeleton", square_location, 3)
		cooldown_progress = 0

func check_cooldown():
	return cooldown - cooldown_progress

func increment_cooldown():
	cooldown_progress += 0.5
	if cooldown_progress > cooldown:
		cooldown_progress = cooldown		

