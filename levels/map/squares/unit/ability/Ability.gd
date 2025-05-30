extends Node2D

class_name Ability

var viable_squares = []

var ability_stats: Ability_Stats
var ability_name         :String
var cooldown              :float
var cooldown_progress     :float
var ability_range           :int
var ability_aoe             :int
var types_viable  :Array[String]
var ability_types         :Array
var ability_vars     :Dictionary


signal determine_viable
signal summon_unit
signal health_change
signal destroy
@onready var unit = get_parent().get_parent()
@onready var building = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("abilities")
	
	ability_name      = ability_stats.ability_name
	cooldown          = ability_stats.cooldown
	ability_range     = ability_stats.ability_range
	ability_aoe       = ability_stats.ability_aoe
	types_viable      = ability_stats.types_viable
	ability_types     = ability_stats.ability_types
	ability_vars      = ability_stats.ability_vars
	cooldown_progress = cooldown

	name = ability_name

func use_ability(target:Array):
	print("USING ABILITY: ",ability_name)
	for ability_type in ability_types:
		var affected_squares = GameData.get_squares(target, ability_aoe, [[0,0],[11,11]])
		
		match ability_type:
			Ability_Stats.ability_type.HEALTH_EFFECT:
				for square in affected_squares:
					if square in viable_squares:
						emit_signal("health_change", ability_vars.health_change, square)
						
			Ability_Stats.ability_type.STATUS_EFFECT:
				for status_effect in ability_vars.status_effects:
					for square in affected_squares:
						if square in viable_squares:
							emit_signal("status_effect", status_effect, square)
				
			Ability_Stats.ability_type.SUMMON:
				print("SUMMONING")
				if ability_vars.conversion == true:
					emit_signal("destroy", target)
					
				emit_signal("summon_unit", unit.unit_color, ability_vars.summon_name, target, {"ai_type":"generic"})
			
			Ability_Stats.ability_type.TRAIN:
				print("TRAINING")
				var square_coord = affected_squares[0]
				var building:Building = get_parent().get_parent()
				print(building.name)
				var train_component:Train
				for node:Node2D in building.get_children():
					print(node.name)
					if node.has_method("train"):
						train_component = node
				if train_component.train(ability_name) == true:
					print("TRAINING IS A SUCCESS")
					print(ability_vars.summon_name)
					emit_signal("summon_unit", building.building_color, ability_vars.summon_name, target, {"ai_type":"generic"})
			
			Ability_Stats.ability_type.GATHER:
				print("GATHERING")
				for square_coord in affected_squares:
					var square = GameData.get_square(square_coord)
					if square_coord in viable_squares:
						var building:Building = square.get_building()
						var gather_component:Gather
						for node:Node2D in building.get_children():
							if node.has_method("gather_resources"):
								gather_component = node
						if gather_component.has_phases: 
							print("HAS PHASES")
							gather_component.advance_phase() #this will automatically gather_resources
						else:
							gather_component.gather_resources()
				pass
				
	cooldown_progress = 0
	
func determine_viable_squares():
	
	var bounds = GameData.get_squares([unit.unit_position[0],unit.unit_position[1]], ability_range, [[0,0],[11,11]] )
	
	var temp_viable_squares = []
	for type_viable in types_viable:
		emit_signal("determine_viable", type_viable, self, bounds)
		for square in viable_squares:
			temp_viable_squares.append(square)
	
	viable_squares = temp_viable_squares
	return viable_squares

func has_viable_placements():
	determine_viable_squares()
	if len(viable_squares) > 0 && cooldown_progress == cooldown: return true
	else:
		return false


func check_cooldown():
	return cooldown - cooldown_progress

func increment_cooldown():

	cooldown_progress = cooldown_progress + 0.5
	
	if cooldown_progress > cooldown:
		cooldown_progress = cooldown		
