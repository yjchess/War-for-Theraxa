class_name  UI_HANDLER extends Node2D

var dirty: bool
var data: Dictionary
var signals_data: Dictionary

var dialogue
var map: Map
var unit_selected
var player_resources
var building_selected

@onready var ui:UI = $CanvasLayer

signal end_turn
signal ability_selected

func _ready() -> void:
	initialize_level_ui(signals_data)

func _update_view():
	if dirty:
		propagate_call("_update_ui", [data])
		dirty = false


func _process(delta):
	_update_view.call_deferred()

func _update_ui(data):
	pass

func _submit_update(key: StringName, value: Variant):
	data[key] = value
	dirty = true

func initialize_level_ui(signals_data):
	dialogue = signals_data["dialogue"]
	ui.surrender.connect(surrender_signal)
	ui.update_minimap_grid()
	ui.end_turn.connect(end_turn_signal)
	ui.ability_pressed.connect(ability_pressed_signal)
	ui.ability_unpressed.connect(ability_unpressed_signal)
	ui.dialogue_finished.connect(dialogue.finished_without_skipping)


func surrender_signal():
	var achievements = signals_data.achievements
	ui.show_winner("computer", achievements.achievements, achievements.special_achievements, achievements.super_special_achievements)

func end_turn_signal():
	emit_signal("end_turn")

func ability_pressed_signal(ability_name):
	unit_selected = signals_data["unit_selected"]
	building_selected = signals_data["building_selected"]
	player_resources = signals_data["player_resources"]
	map = signals_data["map"]
		
	emit_signal("ability_selected", ability_name)
	hide_square_UIs()
	match ability_name:
		"movement": 
			map.show_movable(unit_selected.get_unit_possible_moves())
		"attack"  : 
			map.show_attackable(unit_selected.get_unit_possible_melee_attacks())

		"build"   : ui.show_build_menu("human")
		"gather"  : pass
		"ranged_attack":
			map.show_attackable(unit_selected.get_unit_possible_ranged_attacks())
		"return" : ui.update_abilities(unit_selected.abilities)
		
	match ability_name:
		"farm":
			
			var buildable_squares = unit_selected.get_buildable_squares()
			if buildable_squares != [] && unit_selected.can_build(ability_name, player_resources):
				map.show_buildable(buildable_squares)
				
		"outpost":pass
		"barracks":pass
		"archery_range":pass
		"castle":pass
		"stables":pass
	
	match ability_name:
		"archer":
			var buildable_squares = building_selected.get_buildable_squares()
			if buildable_squares != [] && building_selected.can_build(ability_name, player_resources):
				map.show_buildable(buildable_squares)

func ability_unpressed_signal():
		hide_square_UIs()

func hide_square_UIs():
	get_tree().call_group("attackable_square_UI", "hide")
	get_tree().call_group("movable_square_UI","hide")
	get_tree().call_group("abilitable_square_UI", "hide")
