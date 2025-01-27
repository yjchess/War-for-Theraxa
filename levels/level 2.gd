extends Node2D
@onready var map = $Generic_Map
@onready var ui = $CanvasLayer
@onready var ai = $AI
@onready var mouseblocker = $CanvasLayer/MouseBlocker/Area2D
@onready var dialogue = $Dialogue
var lost_player_unit = false
var level_num = 1
var turns_played = 0
var turn = 1


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

var player_units = []
var computer_units = []

var square_selected   = null
var unit_selected     = null
var building_selected = null

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
	
	ai.game_over = false
	if GameData.is_loading == false:
		map.setup_board(player_troops, computer_troops, player_buildings, computer_buildings, neutral_buildings)
	else:
		map.place_serialized_units(GameData.serialized_player_units, GameData.serialized_computer_units)
		GameData.is_loading = false
	
	map.square_selected.   connect  (square_selected_signal  )
	map.unit_selected.     connect  (unit_selected_signal    )
	map.building_selected. connect  (building_selected_signal)
	
	map.unit_attack.       connect  (unit_attack_signal      )
	map.unit_move.         connect  (unit_move_signal        )
	map.unit_ability.      connect  (unit_ability_signal     )

	map.player_unit_lost.connect(player_unit_lost_signal)
	ai.determine_potential_enemies.connect(determine_potential_enemies_signal)
	
	player_units   = func lambda(): return get_tree().get_nodes_in_group("player_unit")
	computer_units = func lambda(): return get_tree().get_nodes_in_group("computer_unit")
	
	map.update_minimap.connect(ui.update_minimap_grid)
	ui.update_minimap_grid()
	ui.end_turn.connect(end_turn)
	ui.ability_pressed.connect(ability_pressed_signal)
	ui.ability_unpressed.connect(ability_unpressed_signal)
	#ui.save_game.connect(save_game_signal)
	
	#dialogue_finished means that the player let the dialogue run from start to finish
	ui.dialogue_finished.connect(dialogue.finished_without_skipping)
	#mid_dialogue means the player clicked whilst there was still dialogue running
	mouseblocker.mid_dialogue.connect(dialogue.finished_from_middle)
	#end_dialogue means the player clicked once mid dialogue then again
	mouseblocker.end_dialogue.connect(dialogue.new_dialogue)
	
	dialogue.enable_mouse.connect(ui.disable_mouseblocker)
	dialogue.disable_mouse.connect(ui.enable_mouseblocker)
	dialogue.update_cutscene_dialogue.connect(ui.update_cutscene_dialogue)
	dialogue.new_dialogue()
	

func square_selected_signal(coords):
	
	#coords are equal to null when a square has been deselected
	if coords == null:
		square_selected = null
		ui.update_abilities([])
		return
	
	var new_selected_square = map.get_square(coords[0], coords[1])
	if new_selected_square.has_unit() == false:
		unit_selected = null
	if new_selected_square.has_building() == false:
		building_selected = null
	
	if new_selected_square.has_unit() == false and new_selected_square.has_building() == false:
		ui.update_abilities([])
	
	# if the previous square_selected is null - replace it with the new square	
	if square_selected == null:
		square_selected = new_selected_square
		return
	
	#if a square is selected without getting rid of the previous selected square and it isn't the same square:
	elif square_selected != null:
		#square_selected is now the previously selected square and must be deselected before replacing square_selected)
		square_selected.deselect()
		square_selected = new_selected_square
		return
	
func unit_selected_signal(coords, unit):
	unit_selected = unit
	ui.update_portrait    (unit_selected.unit_portrait)
	ui.update_description (unit_selected.unit_name, unit_selected.description)
	ui.update_statistics  (unit_selected.health, unit_selected.max_health, unit_selected.melee_damage, unit_selected.ranged_damage, unit_selected.attack_range, unit_selected.movement_range)
	ui.update_abilities   (unit_selected.abilities)

func building_selected_signal(coords, building):
	building_selected = building
	ui.update_portrait    (building_selected.building_portrait)
	ui.update_description (building_selected.building_name, building_selected.description)
	ui.update_statistics  (building_selected.health, building_selected.max_health, 0, 0, 0, 0)
	ui.update_abilities   (building_selected.abilities)

func unit_attack_signal(coord):
	unit_selected.attack(coord[0], coord[1])

func unit_move_signal(coord):
	unit_selected.move(coord[0],coord[1])
	
func unit_ability_signal():
	pass

func show_attackable_signal(possible_attacks):
	for attack in possible_attacks:
		map.get_square(attack[0], attack[1]).display_attackable()

func player_unit_lost_signal():
	lost_player_unit = true

func check_winner():
	if len(player_units.call()) == 0:
		return "computer"
	elif turns_played > 4 && len(computer_units.call()) == 0:
		ai.game_over = true
		achievements.achievements[0][1] = true
		evaluate_achievements()
		return "player"
	return null

func evaluate_achievements():
	GameData.previously_achieved = GameData.campaign_achievements[level_num-1].duplicate(true)

	if ai.reinforcements != true:
		achievements.achievements[1][1] = true
	elif achievements.achievements[0][1] == true:
		achievements.special_achievements[0][1] = true
		
	if lost_player_unit != true:
		achievements.achievements[2][1] = true
	if lost_player_unit != true && ai.reinforcements == true:
		achievements.special_achievements[1][1] = true
	
	if GameData.campaign_upgrades == [] && len(player_units.call()) >=2 && ai.reinforcements == true:
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

func end_turn():
	get_tree().call_group("movable_square_UI", "hide")
	get_tree().call_group("attackable_square_UI", "hide")
	get_tree().call_group("abilities", "increment_cooldown")
	#update_units()
	await get_tree().create_timer(0.1).timeout #give player_units and computer_units groups time to refresh and see how many units are left
	var winner = check_winner()
	if winner != null:
		ai.game_over = true
		ui.show_winner(winner, achievements.achievements, achievements.special_achievements, achievements.super_special_achievements)
	
	#a full turn is when the player and computer both finish moving
	turns_played += 0.5
	turn += 1
	
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2:
		print("Computer Turn")
		reset_computer_moves()
			
		ai.turn(computer_units.call(), player_units.call(), turns_played)
		if ai.reinforcements == true:
			var potential_reinforcement_squares = range(12).map(func(i): return [i, 11])
			var free_squares = map.get_free_squares(potential_reinforcement_squares)
			if free_squares != []:
				for square in free_squares:
					var x = square[0]
					var y = square[1]
					if len(ai.reinforcement_units) > 0:
						map.place_piece("red", ai.reinforcement_units[0], [x,y], 3)
						ai.reinforcement_units.pop_at(0)
					else:
						break
		
		if turns_played == 3.5:
			map.place_piece("red", "wizard", [0,0], 3)
		end_turn()


func reset_player_moves():
	for unit in player_units.call():
		unit.moved = false	
		unit.attacked = false

func reset_computer_moves():
	for unit in computer_units.call():
		unit.moved = false
		unit.attacked = false

func determine_potential_enemies_signal(enemy_squares):
	var enemies = []
	for square in enemy_squares:
		enemies.append(map.get_square(square[0], square[1]).get_node("Unit"))
	ai.potential_enemies = enemies

func ability_pressed_signal(ability_name):
	match ability_name:
		"movement": 
			hide_square_UIs()
			square_selected.show_unit_movables()
		"attack"  : 
			hide_square_UIs()
			square_selected.show_unit_melee_attackables()
		"build"   : ui.show_build_menu("human")
		"gather"  : pass
		"ranged_attack":
			hide_square_UIs()
			square_selected.show_unit_ranged_attackables()
		"return" : ui.update_abilities(unit_selected.abilities)
	
	match ability_name:
		"farm":pass
		"outpost":pass
		"barracks":pass
		"archery_range":pass
		"castle":pass
		"stables":pass

func ability_unpressed_signal():
	hide_square_UIs()

func hide_square_UIs():
	get_tree().call_group("attackable_square_UI", "hide")
	get_tree().call_group("movable_square_UI","hide")
