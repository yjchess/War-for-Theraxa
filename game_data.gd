extends Node

var is_loading = false
var current_scene

var campaign_upgrades = []
var common_upgrades = [[0,0], [0,0]]
var rare_upgrades   = [[0]]
var campaign_achievements = [
	[
		[false, false, false],
		[false, false],
		[false]
	]
]

var total_gold_gems   = 0
var total_blue_gems   = 0
var total_purple_gems = 0

var available_gold_gems   = 0
var available_blue_gems   = 0
var available_purple_gems = 0

#previously_achieved is dynamically used to fill in achievements that had been previously achieved but are not new
var previously_achieved = []

var serialized_player_units = []
var serialized_computer_units = []
var levels_unlocked = 1

var selected_square
var starting_square_position
var selected_unit
var selected_building
var selected_ability

var map_width
var map_height

#turn = 1 for player, 2 for computer
var turns_played = 0
var turn = 1
var squares
var ui
var ai
var map
var level

var computer_units
var player_units

var computer_buildings
var player_buildings

func connect_button():
	ui.end_turn.connect(end_turn)

func end_turn():
	get_tree().call_group("movable_square_UI", "hide")
	get_tree().call_group("attackable_square_UI", "hide")
	get_tree().call_group("abilities", "increment_cooldown")
	#update_units()
	var winner = level.check_winner()
	if winner != null:
		ai.game_over = true
		ui.show_winner(winner, level.achievements, level.special_achievements, level.super_special_achievements)
	
	#a full turn is when the player and computer both finish moving
	turns_played += 0.5
	turn += 1
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2:
		reset_computer_moves()
		calculate_level_moves()

func remove_unit_from_arrays(unit):
	computer_units.erase(unit)
	player_units.erase(unit)

func reset_player_moves():
	for unit in player_units:
		unit.moved = false	
		unit.attacked = false

func reset_computer_moves():
	for unit in computer_units:
		unit.moved = false
		unit.attacked = false
		
func calculate_level_moves():
	ai.turn()

func calculate_minimap(squares):
	var minimap = []
	for square in squares:
		minimap.append(square.get_player())
	
	return minimap

func update_minimap():
	ui.update_minimap_grid(squares)
	

func update_unit_ui():
	ui.update_portrait(selected_unit.unit_portrait)
	ui.update_description(selected_unit.unit_name, selected_unit.description)
	ui.update_statistics(selected_unit.health, selected_unit.max_health, selected_unit.melee_damage, selected_unit.ranged_damage, selected_unit.attack_range, selected_unit.movement_range)
	ui.update_abilities(selected_unit.abilities)
	
func update_building_ui():
	ui.update_portrait(selected_building.building_portrait)
	ui.update_description(selected_building.building_name, selected_building.description)
	ui.update_statistics(selected_building.health, selected_building.max_health, 0, 0, 0, 0)
	ui.update_abilities(selected_building.abilities)


func get_squares(x_one, x_two, y_one, y_two):
	var squares = []

	for x in range (x_one, x_two+1):
		for y in range (y_one, y_two+1):
			if x > -1 && x < map_width && y >-1 && y < map_height:
				squares.append(map.get_square(x,y))
	
	return squares

func get_free_square(bound_one, bound_two):
	var free_squares = []
	var possible_free_squares = get_squares(bound_one[0], bound_two[0], bound_one[1], bound_two[1])
	for square in possible_free_squares:
		if square.has_unit() == false && square.has_building() == false:
			free_squares.append(square)
	
	return free_squares

func set_winner(winner):
	ui.show_winner(winner, level.achievements, level.special_achievements, level.super_special_achievements)



func save_game():
	calculate_total_gems()
	calculate_available_gems()

	serialized_computer_units = []
	serialized_player_units = []
	print(len(player_units))
	for unit in player_units:
		serialized_player_units.append({"unit_name": unit.unit_name, "unit_health": unit.health, "unit_max_health": unit.max_health, "unit_position": unit.unit_position, "unit_movement_behaviour_id": unit.movement_behaviour_id, "unit_moved":unit.moved, "unit_attacked":unit.attacked})
	
	for unit in computer_units:
		serialized_computer_units.append({"unit_name": unit.unit_name, "unit_health": unit.health, "unit_max_health": unit.max_health, "unit_position": unit.unit_position, "unit_movement_behaviour_id": unit.movement_behaviour_id, "unit_moved":unit.moved, "unit_attacked":unit.attacked})
	
	var saveData = {}
	
	current_scene = get_tree().current_scene.scene_file_path
	saveData["currentScene"] = current_scene
	
	if "levels/level" in saveData["currentScene"]:
		saveData["turnsPlayed"]   = turns_played
		saveData["playerUnits"]   = serialized_player_units
		saveData["computerUnits"] = serialized_computer_units
	
	saveData["commonUpgrades"]       = common_upgrades
	saveData["rareUpgrades"]         = rare_upgrades
	saveData["campaignUpgrades"]     = campaign_upgrades
	saveData["previouslyAchieved"]   = previously_achieved
	saveData["campaignAchievements"] = campaign_achievements
	saveData["levelsUnlocked"]       = levels_unlocked
	
	var jsonString = JSON.stringify(saveData)
	var jsonFile = FileAccess.open("res://savegame.json", FileAccess.WRITE)
	jsonFile.store_line(jsonString)
	jsonFile.close()

func load_game():
	computer_units = []
	player_units = []
	serialized_computer_units = []
	serialized_player_units = []

	is_loading = true
	var jsonFile = FileAccess.open("res://savegame.json", FileAccess.READ)
	var json = jsonFile.get_as_text()
	var saveData = JSON.parse_string(json)
	
	common_upgrades       = saveData["commonUpgrades"]
	rare_upgrades         = saveData["rareUpgrades"]
	campaign_achievements = saveData["campaignAchievements"] 
	levels_unlocked       = saveData["levelsUnlocked"]
	current_scene         = saveData["currentScene"]
	
	if "levels/level" in current_scene:
		turns_played              = saveData["turnsPlayed"]
		serialized_player_units   = saveData["playerUnits"]
		serialized_computer_units = saveData["computerUnits"]
		previously_achieved       = saveData["previouslyAchieved"]
	
	if get_tree().current_scene.scene_file_path == current_scene:
		get_tree().reload_current_scene()
		await get_tree().process_frame
	else:
		get_tree().change_scene_to_file(current_scene)
		await get_tree().process_frame
		
	is_loading = false
	jsonFile.close()

func calculate_total_gems():
	
	total_gold_gems   = 0
	total_blue_gems   = 0
	total_purple_gems = 0
	
	for achievement_set in campaign_achievements:
		for gem in achievement_set[0]:
			if gem == true:
				total_gold_gems   += 1
		
		for gem in achievement_set[1]:
			if gem == true:
				total_blue_gems   += 1
		
		for gem in achievement_set[2]:
			if gem == true:
				total_purple_gems += 1

func calculate_available_gems():
	var used_gold_gems = 0
	var used_blue_gems = 0
	for upgrade in common_upgrades:
		used_gold_gems += upgrade[0]
		used_blue_gems += upgrade [1]
	
	var used_purple_gems = 0
	for upgrade in rare_upgrades:
		used_purple_gems += upgrade[0]
		
	available_gold_gems   = total_gold_gems   - used_gold_gems
	available_blue_gems   = total_blue_gems   - used_blue_gems
	available_purple_gems = total_purple_gems - used_purple_gems

func ability_pressed(ability):
	if GameData.selected_unit != null:
		selected_unit.get_ability(ability).show_viable_moves()
		
