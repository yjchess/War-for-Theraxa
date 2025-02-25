extends AI
class_name FAST_AI

var destination: Array

func _init(new_unit, new_ai_vars):
	unit = new_unit
	ai_vars = new_ai_vars
	destination = ai_vars.destination
	

func calculate_best_movement_option(player_units):
	return fastest_route(destination)
