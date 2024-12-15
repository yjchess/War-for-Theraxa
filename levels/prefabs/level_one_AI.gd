extends Node2D
#var computer_units = []
#var player_units = []
var reinforcements = false
var reinforcement_units = ["warrior", "warrior", "archer", "cavalry_warrior"]
var game_over = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func turn(computer_units, player_units):
	if game_over == false:
		for unit in computer_units:
			var calculated_move = calculate_best_movement_option(unit, player_units)
			if calculated_move != null:
				unit.move(calculated_move[0], calculated_move[1])
		
		for unit in computer_units:
			if unit.abilities_holder.get_child_count() > 0:
				var calculated_ability = calculate_best_ability_options(unit, player_units)
				if calculated_ability != null:
					unit.use_ability(calculated_ability[0], calculated_ability[1])
				
		for unit in computer_units:
			var calculated_attack = calculate_best_attack_options(unit)
			if calculated_attack != null:
				unit.attack(calculated_attack[0], calculated_attack[1])
		
		for unit in computer_units:
			if unit.unit_position[1] == 11:
				unit.movement_behaviour_id = 3
				reinforcements = true
		
		if GameData.turns_played == 3.5:
			print("PLACE WIZARD")
			GameData.map.place_piece("red", "wizard", [0,0], 3)
		
		if reinforcements == true:
			var free_squares = GameData.get_free_square([0,11],[11,11])
			if free_squares != []:
				for square in free_squares:
					var x = square.x_coord
					var y = square.y_coord
					if len(reinforcement_units) > 0:
						GameData.map.place_piece("red", reinforcement_units[0], [x,y], 3)
						reinforcement_units.pop_at(0)
					else:
						break
					
		#GameData.end_turn()
	else:
		print("GAME OVER")


func calculate_best_movement_option(unit, player_units):
	if unit.movement_behaviour_id == 1:
		return fastest_route(unit, [5,11])
	if unit.movement_behaviour_id == 2:
		return fastest_route(unit, [6,11])
	
	if unit.movement_behaviour_id == 3:
		return move_towards_closest_enemy(unit, player_units)

func fastest_route(unit, destination):
	var possible_moves = unit.get_unit_possible_moves()
	var closest_move = null
	if len(possible_moves) > 0 && unit.unit_position != destination:
		for possible_move in possible_moves:
			closest_move = get_closest(destination, closest_move, possible_move)
		closest_move = get_closest(destination, closest_move, unit.unit_position)
	
	if closest_move == unit.unit_position:
		return null

	return closest_move
			
func move_towards_closest_enemy(unit, player_units):
	var closest_enemy = calculate_closest_enemy(unit, player_units)
	if closest_enemy != null:
		var closest_move = fastest_route(unit, closest_enemy.unit_position)
		return closest_move
	#if there aren't enemy units simply don't move
	return null
	

func calculate_closest_enemy(unit, player_units):
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

func calculate_best_attack_options(unit):
	return greatest_damage_weakest_enemy(unit)

func greatest_damage_weakest_enemy(unit):
	
	var lowest_health = 999
	var lowest_enemy
	var potential_enemies_squares = unit.get_unit_possible_attacks()
	var potential_enemies = []
	
	if len(potential_enemies_squares) == 0:
		return null

	
	for square in potential_enemies_squares:
		potential_enemies.append(GameData.map.get_square(square[0], square[1]).get_node("Unit"))
	
	for enemy in potential_enemies:
		if enemy.health < lowest_health:
			lowest_enemy = enemy
	
	return lowest_enemy.unit_position

	
func calculate_best_ability_options(unit, player_units):
	var chosen_ability = null
	var chosen_location = null
	for ability in unit.abilities_holder.get_children():
		#operating on the logic that later skills are more powerful
		if ability.check_cooldown() == 0 && ability.has_viable_placements():
			chosen_ability = ability.name
		else:
			return null
		
		if ability.type_viable == "empty":
			var target = calculate_closest_enemy(unit, player_units)
			
			if target == null:
				target = [0,0]
			else:
				target = target.unit_position
				
			for square in ability.viable_squares():
				chosen_location = get_closest(target, chosen_location, square)
				
		else:
			chosen_location = ability.viable_squares()[0]
	return [chosen_ability, chosen_location]
