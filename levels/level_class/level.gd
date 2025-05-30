extends Node2D

class_name Level


@onready var map:Map = $Generic_Map
@onready var ui_handler:UI_HANDLER = $UI_Handler
@onready var ui:UI = $UI_Handler/CanvasLayer
@onready var level_handler:LEVEL_HANDLER = $LEVEL_HANDLER
@onready var ai = $AI
@onready var mouseblocker = $UI_Handler/CanvasLayer/MouseBlocker/Area2D
@onready var dialogue:Dialogue = $Dialogue
var lost_player_unit = false
var level_num = 1
var turns_played = 0
var turn = 1

@onready var achievements = $Achievements
var player_troops: Array[Unit_Spawn]
var player_buildings = [[]]
var computer_troops: Array[Unit_Spawn]
var computer_buildings = [[]]
var neutral_buildings = [[]]
var environmental_buildings = [[]]
var neutral_units = [[]]

var player_units = []
var computer_units = []

var square_selected   = null
var unit_selected:Unit= null
var building_selected = null
var current_entity_selected = ""

var ability_selected

var player_resources = {"food":100, "gold":100}
var computer_resources = {"food":0, "gold":0}

signal submit_ui_update (StringName, Variant)


func _ready():
	#ui.surrender.connect(surrender_signal)

	ai.game_over = false
	if GameData.is_loading == false:
		map.setup_board(player_troops, computer_troops, player_buildings, computer_buildings, environmental_buildings, neutral_buildings, neutral_units)
		
	else:
		map.place_serialized_units(GameData.serialized_player_units, GameData.serialized_computer_units)
		GameData.is_loading = false
	
	ui_handler.initialize_level_ui()
	ui_handler.end_turn.connect(end_turn)
	ui_handler.ability_selected.connect(ability_selected_signal)
	
	map.square_selected.   connect  (square_selected_signal  )
	map.unit_selected.     connect  (unit_selected_signal    )
	map.building_selected. connect  (building_selected_signal)
	
	map.unit_attack.       connect  (unit_attack_signal      )
	map.unit_move.         connect  (unit_move_signal        )
	map.entity_ability.    connect  (entity_ability_signal   )

	map.player_unit_lost.connect(player_unit_lost_signal)
	
	player_units   = func lambda(): return get_tree().get_nodes_in_group("player_unit")
	computer_units = func lambda(): return get_tree().get_nodes_in_group("computer_unit")
	
	map.update_minimap.connect(ui.update_minimap_grid)
	#ui.save_game.connect(save_game_signal)
	
	#dialogue_finished means that the player let the dialogue run from start to finish
	#ui.dialogue_finished.connect(dialogue.finished_without_skipping)
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
	current_entity_selected = "unit"
	submit_ui_update.emit("unit_selected", unit_selected)

func building_selected_signal(coords, building):
	building_selected = building
	ui.update_portrait    (building_selected.building_portrait)
	ui.update_description (building_selected.building_name, building_selected.description)
	ui.update_statistics  (building_selected.health, building_selected.max_health, 0, 0, 0, 0)
	ui.update_abilities   (building_selected.abilities)
	current_entity_selected = "building"
	submit_ui_update.emit("building_selected", building_selected)

func unit_attack_signal(coord):
	unit_selected.attack(coord[0], coord[1])

func unit_move_signal(coord):
	unit_selected.move(coord[0],coord[1])
	
func entity_ability_signal(coord):
	if current_entity_selected == "unit":
		print("UNIT USING ABILITY")
		unit_selected.use_ability(ability_selected, coord)
	else:
		print("BUILDING USING ABILITY")
		building_selected.use_ability(ability_selected, coord)


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
	print(GameData.campaign_achievements)

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
	
	else:
		#a full turn is when the player and computer both finish moving
		turns_played += 0.5
		turn += 1
		
		level_specifics()
	
	
func surrender_signal():
	ui.show_winner("computer", achievements.achievements, achievements.special_achievements, achievements.super_special_achievements)

func level_specifics():
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2 && ai.game_over == false:
		print("Computer Turn")
		reset_computer_moves()
		ai.turn(computer_units.call(), player_units.call(), turns_played)
		end_turn()

func reset_player_moves():
	for unit in player_units.call():
		unit.moved = false	
		unit.attacked = false
		unit.built = false

func reset_computer_moves():
	for unit in computer_units.call():
		unit.moved = false
		unit.attacked = false
		unit.built = false


func ability_unpressed_signal():
	hide_square_UIs()

func hide_square_UIs():
	get_tree().call_group("attackable_square_UI", "hide")
	get_tree().call_group("movable_square_UI","hide")
	get_tree().call_group("abilitable_square_UI", "hide")


func unit(name, location, ai_vars = ["generic"]):
	return Unit_Spawn.new(name, location, ai_vars)

func ability_selected_signal(ability):
	print("ABILITY SELECTED:",ability)
	ability_selected = ability
