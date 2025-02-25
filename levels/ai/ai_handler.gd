extends Node2D

var game_over = false

func turn(computer_units, player_units, turns_played):
	if game_over == false:
		for unit in computer_units:
			var calculated_move = unit.ai.calculate_best_movement_option(player_units)
			if calculated_move != null:
				unit.move(calculated_move[0], calculated_move[1])
		
		for unit in computer_units:
			if unit.abilities_holder.get_child_count() > 0:
				var calculated_ability = unit.ai.calculate_best_ability_options(player_units)
				if calculated_ability != null:
					unit.use_ability(calculated_ability[0], calculated_ability[1])
				
		for unit in computer_units:
			var calculated_attack = unit.ai.calculate_best_attack_options()
			if calculated_attack != null:
				unit.attack(calculated_attack[0], calculated_attack[1])
		
	else:
		print("GAME OVER")
