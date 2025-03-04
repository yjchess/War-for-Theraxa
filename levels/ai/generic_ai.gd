class_name AI extends Resource
#var computer_units = []
#var player_units = []
var game_over = false
var viable_squares = []
var potential_enemies = []
var unit
@export var ai_vars:Dictionary
signal determine_potential_enemies

func _init(new_unit, new_ai_vars):
	unit = new_unit
	ai_vars = new_ai_vars

func calculate_best_movement_option(player_units):
	return move_towards_closest_enemy(player_units)

func fastest_route(destination):
	var possible_moves = unit.get_unit_possible_moves()
	var closest_move = null
	if len(possible_moves) > 0 && unit.unit_position != destination:
		for possible_move in possible_moves:
			closest_move = get_closest(destination, closest_move, possible_move)
		closest_move = get_closest(destination, closest_move, unit.unit_position)
	
	if closest_move == unit.unit_position:
		return null

	return closest_move

func move_towards_closest_enemy(player_units):
	var closest_enemy = calculate_closest_enemy(player_units)
	if closest_enemy != null:
		var closest_move = fastest_route(closest_enemy.unit_position)
		return closest_move
	#if there aren't enemy units simply don't move
	return null

func calculate_closest_enemy(player_units):
	var closest_unit = null
	var closest_distance = 999
	if len(player_units) > 0:
		for player_unit in player_units:
			var player_unit_location = player_unit.unit_position
			var self_position = unit.unit_position
			
			var x_distance = abs(self_position[0] - player_unit_location[0])
			var y_distance = abs(self_position[1] - player_unit_location[1])
			var hypotenuse = sqrt(x_distance**2 + y_distance**2)
			
			if hypotenuse < closest_distance:
				closest_distance = hypotenuse
				closest_unit = player_unit
			
			#if the distance is the same, pick the unit closest in the y direction if possible.
			if hypotenuse == closest_distance:
				var closest_unit_position = closest_unit.unit_position
				var previous_closest_unit_y_distance =  abs(self_position[1] - closest_unit_position[1])
				if y_distance < previous_closest_unit_y_distance:
					closest_unit = player_unit
				
				#if y_distance is the same then x_distance must also be the same for them to be the same distance
				#if y_distance == previous_closest_unit_y_distance:
				#	var previous_closest_unit_x_distance = abs(self_position[0] - closest_unit_position[0])
				#	if x_distance < previous_closest_unit_x_distance:
				#		closest_unit = player_unit
					
				#if x_distance is the same prioritise down over up, left over right
				var previous_closest_unit_x_distance = abs(self_position[0] - closest_unit_position[0])
				if x_distance == previous_closest_unit_x_distance:
					if player_unit_location[1] < closest_unit_position[1]:
						closest_unit = player_unit
					elif player_unit_location[0] < closest_unit_position[0]:
						closest_unit = player_unit
	
	return closest_unit 

func get_closest(position_one, position_two_a, position_two_b):
	if position_two_a == null:
		return position_two_b
	
	if position_two_a == position_two_b:
		print("They are the same position")
		return position_two_a
	
	var x_distance_a = abs(position_two_a[0] - position_one[0])
	var y_distance_a = abs(position_two_a[1] - position_one[1])
	var hypotenuse_a = sqrt(x_distance_a**2 + y_distance_a**2)	

	var x_distance_b = abs(position_two_b[0] - position_one[0])
	var y_distance_b = abs(position_two_b[1] - position_one[1])
	var hypotenuse_b = sqrt(x_distance_b**2 + y_distance_b**2)
	#note x**2 != x^2. x^2 means x Bitwise XOR 2, which somehow still got my units to the end although they drifted left
	
	if hypotenuse_a < hypotenuse_b:   return position_two_a
	elif hypotenuse_b < hypotenuse_a: return position_two_b
	
	elif hypotenuse_a == hypotenuse_b:
		
		if position_two_a[1] > position_two_b[1]:       return position_two_a
		elif position_two_b[1] > position_two_a[1]:     return position_two_b
		
		elif position_two_a[1] == position_two_b[1]:
	
			if position_two_a[0] < position_two_b[0]:   return position_two_a
			elif position_two_b[0] < position_two_a[0]: return position_two_b
	
	return null

func calculate_best_attack_options():
	return greatest_damage_weakest_enemy()

func greatest_damage_weakest_enemy():

	var lowest_health = 999
	var lowest_enemy
	var potential_enemies_squares = unit.get_unit_possible_attacks()
	if potential_enemies_squares == null: potential_enemies_squares = []
	if len(potential_enemies_squares) == 0: return null
	emit_signal("determine_potential_enemies", self, potential_enemies_squares)
	if len(potential_enemies) == 0: return null

	for enemy in potential_enemies:
		if enemy.health < lowest_health:
			lowest_enemy = enemy
	
	return lowest_enemy.unit_position

func calculate_best_ability_options(player_units):
	var chosen_ability = null
	var chosen_location = null
	for ability:Ability in unit.abilities_holder.get_children():
		#operating on the logic that later skills are more powerful
		if ability.check_cooldown() == 0 && ability.has_viable_placements():
			chosen_ability = ability.name
		else:
			return null
		
		if ability.types_viable == ["empty"] || ability.types_viable == ["special_building"] && ability.ability_types == [Ability_Stats.ability_type.SUMMON]:
			var target = calculate_closest_enemy(player_units)
			
			if target == null: target = [0,0]
			else: target = target.unit_position
			
			for square in ability.viable_squares:
				chosen_location = get_closest(target, chosen_location, square)
				
		else:
			chosen_location = ability.viable_squares[0]
			
	return [chosen_ability, chosen_location]
