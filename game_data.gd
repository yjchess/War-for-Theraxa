extends Node

var selected_square
var starting_square_position
var selected_unit

var map_width
var map_height

#turn = 1 for player, 2 for computer
var turn = 1
var squares
var ui
var ai
var map

var computer_units
var player_units

func connect_button():
	ui.end_turn.connect(end_turn)

func end_turn():
	get_tree().call_group("movable_square_UI", "hide")
	get_tree().call_group("attackable_square_UI", "hide")
	update_units()
	
	turn += 1
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2:
		reset_computer_moves()
		calculate_level_moves()

func update_units():
	print(computer_units)
	for object in computer_units:
		if object == null:
			computer_units.erase(object)
	print(computer_units)
	
	for object in player_units:
		if object == null:
			player_units.erase(object)

func reset_player_moves():
	for unit in player_units:
		unit.moved = false

func reset_computer_moves():
	for unit in computer_units:
		unit.moved = false

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
