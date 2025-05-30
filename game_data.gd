class_name GD
extends Node

var is_loading = false
var current_scene

var campaign_upgrades = []
var common_upgrades = [[0,0], [0,0]]

enum upgrade_keys{
	UNIT_UPGRADE,
	YELLOW_GEM_UPGRADES,
	BLUE_GEM_UPGRADES,
	PURPLE_GEM_UPGRADES,
}

enum achievement_keys{
	LEVEL,
	YELLOW_GEM_ACHIEVEMENTS,
	BLUE_GEM_ACHIEVEMENTS,
	PURPLE_GEM_ACHIEVEMENTS
}

var common_upgrades_new = [
	{upgrade_keys.UNIT_UPGRADE: "warrior_upgrades",upgrade_keys.YELLOW_GEM_UPGRADES:0, upgrade_keys.BLUE_GEM_UPGRADES:0},
	{upgrade_keys.UNIT_UPGRADE: "archer_upgrades" ,upgrade_keys.YELLOW_GEM_UPGRADES:0, upgrade_keys.BLUE_GEM_UPGRADES:0}
]

var campaign_achievements_new = [
	{achievement_keys.LEVEL: 1, achievement_keys.YELLOW_GEM_ACHIEVEMENTS: [false, false, false], achievement_keys.BLUE_GEM_ACHIEVEMENTS: [false,false], achievement_keys.PURPLE_GEM_ACHIEVEMENTS: [false]}
]

var rare_upgrades_new = [
	{upgrade_keys.UNIT_UPGRADE: "Commander_Jensen",upgrade_keys.PURPLE_GEM_UPGRADES:0},
]

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

#turn = 1 for player, 2 for computer
var turns_played = 0
var turn = 1
var squares
var ui
#var ai
var map
var level

var computer_units
var player_units

var computer_buildings
var player_buildings



func set_winner(winner):
	ui.show_winner(winner, level.achievements, level.special_achievements, level.super_special_achievements)



func save_game():
	calculate_total_gems()
	calculate_available_gems()

	serialized_computer_units = []
	serialized_player_units = []
	print("PLAYER UNITS ",len(player_units))
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

func get_squares(center, range, bounds):
	var squares = []
	var potential_squares = []
	for x in range (center[0]-range, center[0]+range+1):
		for y in range(center[1]-range, center[1]+range+1):
			potential_squares.append([x,y])
	
	for square in potential_squares:
		if     square[0] >= bounds[0][0] && square[0] <= bounds[1][0]:
			if square[1] >= bounds[0][1] && square[1] <= bounds[1][1]:
				squares.append(square)
	return squares

func get_square(coord):
	var map = get_node("/root/Level/Generic_Map")
	return map.get_square(coord[0], coord[1])
