extends Node

var selected_square
var starting_square_position
var selected_unit

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

func connect_button():
	ui.end_turn.connect(end_turn)

func end_turn():
	get_tree().call_group("movable_square_UI", "hide")
	get_tree().call_group("attackable_square_UI", "hide")
	get_tree().call_group("abilities", "increment_cooldown")
	#update_units()
	var winner = level.check_winner()
	if winner != null:
		ui.show_winner(winner, level.achievements, level.special_achievements)
	
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


func get_squares(x_one, x_two, y_one, y_two):
	var squares = []

	for x in range (x_one, x_two+1):
		for y in range (y_one, y_two+1):
			if x > -1 && x < map_width && y >-1 && y < map_height:
				squares.append(map.get_square(x,y))
	
	return squares

