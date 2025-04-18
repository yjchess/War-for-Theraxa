extends Level
var reinforcements = false
var reinforcement_units = ["warrior", "warrior", "archer", "cavalry_warrior"]

func _init():
	player_troops = [unit("warrior", [1,10]), unit("warrior",[2,10]), unit("archer",[1,11]), unit("archer",[2,11]), unit("warrior",[9,10]), unit("warrior",[10,10]), unit("archer",[9,11]), unit("archer",[10,11])]
	computer_troops = [unit("warrior", [1,1], ["generic"]), unit("warrior", [2,1], ["generic"]), unit("cavalry_warrior",[1,0],["fastest",[5,11]]), unit("warrior", [9,1], ["generic"]), unit("warrior", [10,1], ["generic"]), unit("cavalry_warrior", [10,0], ["fastest",[6,11]])]

func level_specifics():
	for unit in computer_units.call():
		if unit.unit_position[1] == 11 and unit.ai.ai_vars.ai_type=="fastest_route":
			unit.ai = AI.new(unit, {"ai_type":"generic"})
			unit.connect_ai_determine_potential_enemies_signal()
			reinforcements = true
	
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2 && ai.game_over == false:
		print("Computer Turn")
		reset_computer_moves()
		ai.turn(computer_units.call(), player_units.call(), turns_played)
		if reinforcements == true:
			var potential_reinforcement_squares = range(12).map(func(i): return [i, 11])
			var free_squares = map.get_free_squares(potential_reinforcement_squares)
			if free_squares != []:
				for square in free_squares:
					var x = square[0]
					var y = square[1]
					if len(reinforcement_units) > 0:
						map.place_piece("red", reinforcement_units[0], [x,y], {"ai_type":"generic"})
						reinforcement_units.pop_at(0)
					else:
						break
		
		if turns_played == 3.5:
			map.place_piece("red", "wizard", [0,0], {"ai_type":"generic"})
		end_turn()
		
func evaluate_achievements():
	GameData.previously_achieved = GameData.campaign_achievements[level_num-1].duplicate(true)
	print(GameData.campaign_achievements)

	if reinforcements != true:
		achievements.achievements[1][1] = true
	elif achievements.achievements[0][1] == true:
		achievements.special_achievements[0][1] = true
		
	if lost_player_unit != true:
		achievements.achievements[2][1] = true
	if lost_player_unit != true && reinforcements == true:
		achievements.special_achievements[1][1] = true
	
	if GameData.campaign_upgrades == [] && len(player_units.call()) >=2 && reinforcements == true:
		achievements.super_special_achievements[0][1] = true
	
	
	var corresponding_saved_achievements = GameData.campaign_achievements[level_num-1].duplicate()
	
	var count = 0
	for achievement in achievements.achievements:
		if achievement[1] == true:
			corresponding_saved_achievements[0][count] = true
		count += 1
	
	count = 0
	for achievement in achievements.special_achievements:
		if achievement[1] == true:
			corresponding_saved_achievements[1][count] = true
		count += 1
	
	count = 0
	for achievement in achievements.super_special_achievements:
		if achievement[1] == true:
			corresponding_saved_achievements[2][count] = true
		count += 1

	GameData.campaign_achievements[level_num-1] = corresponding_saved_achievements
