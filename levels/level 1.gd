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

@onready var achievements = $Achievements
var player_troops =   [["warrior", [1,10]],["warrior", [2,10]], ["archer", [1,11]],["archer", [2,11]], ["warrior", [9,10]],["warrior", [10,10]], ["archer", [9,11]],["archer", [10,11]]]
var player_buildings = [[]]
var computer_troops = [["warrior", [1,1], 3], ["warrior", [2,1], 3], ["cavalry_warrior", [1,0], 1], ["warrior", [9,1],3], ["warrior", [10,1],3], ["cavalry_warrior", [10,0],2]]
var computer_buildings = [[]]
var neutral_buildings = [[]]

var player_units = []
var computer_units = []

var square_selected   = null
var unit_selected     = null
var building_selected = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#GameData.level = self
	#GameData.ui = ui
	$AI.game_over = false
	if GameData.is_loading == false:
		GameData.turns_played = 0
		GameData.turn = 1
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
	
	player_units   = func lambda(): return get_tree().get_nodes_in_group("player_unit")
	computer_units = func lambda(): return get_tree().get_nodes_in_group("computer_unit")
	
	map.update_minimap.connect(ui.update_minimap_grid)
	ui.update_minimap_grid()
	ui.end_turn.connect(end_turn)
	GameData.map = map
	
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
	if square_selected == null:
		square_selected = coords
		return
	
	#if a square is selected twice, the square script automatically deselects it	
	#if a square is selected without getting rid of the previous selected square and it isn't the same square:
	elif square_selected != null:
		#square_selected is now the previously selected square and must be deselected before replacing square_selected)
		map.get_square(square_selected[0],square_selected[1]).deselect()
		square_selected = coords
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
		$AI.game_over = true
		achievements.achievements[0][1] = true
		evaluate_achievements()
		return "player"
	return null

func evaluate_achievements():
	GameData.previously_achieved = GameData.campaign_achievements[level_num-1].duplicate(true)

	if $AI.reinforcements != true:
		achievements.achievements[1][1] = true
	elif achievements.achievements[0][1] == true:
		achievements.special_achievements[0][1] = true
		
	if lost_player_unit != true:
		achievements.achievements[2][1] = true
	if lost_player_unit != true && $AI.reinforcements == true:
		achievements.special_achievements[1][1] = true
	
	if GameData.campaign_upgrades == [] && len(player_units.call()) >=2 && $AI.reinforcements == true:
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
	print(str(turns_played) +" "+ str(turn))
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2:
		#GameData.turn = 2
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
