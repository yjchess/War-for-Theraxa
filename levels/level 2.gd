extends Node2D
@onready var map = $Generic_Map
@onready var ui = $CanvasLayer
@onready var mouseblocker = $CanvasLayer/MouseBlocker/Area2D
var lost_player_unit = false
var level_num = 1

var achievements = [["Beat the level",false], ["Don't let enemy troops call for reinforcements",false], ["Win without losing a single troop", false]]
var special_achievements = [["Beat the level after letting reinforcements come", false], ["Let reinforcements arrive and beat them without losing a unit", false]]
var super_special_achievements = [["Beat reinforments, don't use campaign upgrades, have 2+ units at the end", false]]

var player_troops =   [["peasant", [1,11]], ["peasant", [2,11]], ["peasant", [11,11]]]
var computer_troops = [["warrior", [1,1], 3], ["warrior", [2,1], 3], ["cavalry_warrior", [1,0], 1], ["warrior", [9,1],3], ["warrior", [10,1],3], ["cavalry_warrior", [10,0],2]]

var player_buildings = [["outpost",[8,7]],["barracks",[8,10]],["archery_range",[9,10]],["stables",[10,10]], ["gold_mine",[1,10]],["gold_mine",[2,10]],["farm",[1,9]],["farm",[2,9]]]
var computer_buildings = [[]]

var neutral_buildings = [["forest",[0,6]],["forest",[0,7]],["forest",[1,6]],["forest",[1,7]],["forest",[2,6]],["forest",[2,7]],["forest",[3,6]],["forest",[3,7]], ["forest",[3,8]], ["forest",[4,6]],["forest",[4,7]], ["forest",[4,8]], ["forest",[4,9]], ["forest",[5,6]],["forest",[5,7]], ["forest",[5,8]], ["forest",[7,7]], ["forest",[8,6]],["forest",[9,7]],["forest",[10,7]]]

var current_dialogue = 0
var current_dialogue_set = 0
var in_dialogue = true
var start_new_dialogue = false

var keys = ["portrait", "name", "description"]
var campaign_dialogue = [
	[
		{keys[0]: "res://assets/portraits/commander_jensen.png", keys[1]: "Commander Jensen", keys[2]: "[b]General Zardinius, troops at our outermost outpost have discovered an enemy scouting group! We must destroy them before they contact General Eelzeroth lest they send for reinforcements to break through our defenses![/b]"},
		{keys[0]: "res://assets/portraits/commander_jensen.png", keys[1]: "Commander Jensen", keys[2]: "[b]TEST! Test test test[/b]"},
		{keys[0]: "res://assets/portraits/commander_jensen.png", keys[1]: "Commander Jensen", keys[2]: "[b]TEST2! sad asd dsa[/b]"},
	]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.level = self
	GameData.ui = ui
	$AI.game_over = false
	if GameData.is_loading == false:
		GameData.turns_played = 0
		GameData.turn = 1
		map.setup_board(player_troops, computer_troops, player_buildings, computer_buildings, neutral_buildings)
	else:
		map.place_serialized_units(GameData.serialized_player_units, GameData.serialized_computer_units)
		GameData.is_loading = false
		
	#GameData.update_minimap()
	GameData.connect_button()
	GameData.map = map
	
	#dialogue_finished means that the player let the dialogue run from start to finish
	ui.dialogue_finished.connect(finished_without_skipping)
	#mid_dialogue means the player clicked whilst there was still dialogue running
	mouseblocker.mid_dialogue.connect(finished_from_middle)
	#end_dialogue means the player clicked once mid dialogue then again
	mouseblocker.end_dialogue.connect(new_dialogue)
	
	new_dialogue()
	#var dialogue = campaign_dialogue[0][0]
	#ui.enable_mouseblocker()	
	#ui.update_cutscene_dialogue(dialogue.portrait, dialogue.name, dialogue.description)
	
func finished_from_middle():
	start_new_dialogue = false
	current_dialogue += 1

func finished_without_skipping():
	start_new_dialogue = false
	current_dialogue += 1
		
func new_dialogue():	
	if current_dialogue_set > (len(campaign_dialogue)-1):
		print("END OF CAMPAIGN DIALOGUE")
		ui.disable_mouseblocker()
		return
		
	if current_dialogue > len(campaign_dialogue[current_dialogue_set])-1:
		current_dialogue_set += 1
		current_dialogue = 0
		ui.disable_mouseblocker()
		return
		
	

	#if a characters has finished speaking - move on to the next piece of dialogue if there is one
	if start_new_dialogue == true:
		current_dialogue += 1	
		start_new_dialogue = false
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		ui.enable_mouseblocker()
		ui.update_cutscene_dialogue(dialogue.portrait, dialogue.name, dialogue.description)
		
	elif start_new_dialogue == false:
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		ui.enable_mouseblocker()
		ui.update_cutscene_dialogue(dialogue.portrait, dialogue.name, dialogue.description)
		
func check_winner():
	if len(GameData.player_units) == 0:
		return "computer"
	elif GameData.turns_played > 4 && len(GameData.computer_units) == 0:
		$AI.game_over = true
		achievements[0][1] = true
		evaluate_achievements()
		return "player"
	return null

func evaluate_achievements():
	GameData.previously_achieved = GameData.campaign_achievements[level_num-1].duplicate(true)

	if $AI.reinforcements != true:
		achievements[1][1] = true
	elif achievements[0][1] == true:
		special_achievements[0][1] = true
		
	if lost_player_unit != true:
		achievements[2][1] = true
	if lost_player_unit != true && $AI.reinforcements == true:
		special_achievements[1][1] = true
	
	if GameData.campaign_upgrades == [] && len(GameData.player_units) >=2 && $AI.reinforcements == true:
		super_special_achievements[0][1] = true
	
	
	var corresponding_saved_achievements = GameData.campaign_achievements[level_num-1].duplicate()
	
	var count = 0
	for achievement in achievements:
		if achievement[1] == true:
			corresponding_saved_achievements[0][count] = true
		count += 1
	
	count = 0
	for achievement in special_achievements:
		if achievement[1] == true:
			corresponding_saved_achievements[1][count] = true
		count += 1
	
	count = 0
	for achievement in super_special_achievements:
		if achievement[1] == true:
			corresponding_saved_achievements[2][count] = true
		count += 1

	GameData.campaign_achievements[level_num-1] = corresponding_saved_achievements
