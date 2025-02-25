extends AI
class_name PRE_DETERMINED_AI

var pacifist: bool
var pre_determined_moves: Array

func _init(new_unit, new_ai_vars):
	super(new_unit, new_ai_vars)
	pre_determined_moves = ai_vars.pre_determined_moves
	pacifist = ai_vars.pacifist
	

func calculate_best_movement_option(player_units):
	var next_move = fastest_route(pre_determined_moves[0])
	
	#The following algorithm takes into account if the unit is blocked - but can be improved
	if len(pre_determined_moves) > 1: 
		pre_determined_moves.pop_at(0)
		
	return next_move

func calculate_best_attack_options():
	if pacifist == false:
		return greatest_damage_weakest_enemy()
	else:
		return null
