extends Node2D

class_name Ability

var viable_squares = []

var ability_stats: Ability_Stats
var ability_name       :String
var cooldown              :int
var cooldown_progress     :int
var ability_range         :int
var ability_aoe           :int
var types_viable :Array[String]
var ability_types       :Array
var ability_vars   :Dictionary


signal determine_viable
signal summon_unit
signal health_change
signal destroy
@onready var unit = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	ability_name      = ability_stats.ability_name
	cooldown          = ability_stats.cooldown
	ability_range     = ability_stats.ability_range
	ability_aoe       = ability_stats.ability_aoe
	types_viable      = ability_stats.types_viable
	ability_types     = ability_stats.ability_types
	ability_vars      = ability_stats.ability_vars

	name = ability_name

func use_ability(target:Array[int]):
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
				if ability_vars.conversion == true:
					emit_signal("destroy", target)
					
				emit_signal("summon_unit", unit.unit_color, ability_vars.summon_name, target, {"ai_type":"generic"})
				
	
func determine_viable_squares():
	var bound_one = [unit.unit_position[0] - ability_range, unit.unit_position[1] - ability_range]
	var bound_two = [unit.unit_position[0] + ability_range, unit.unit_position[1] + ability_range]
	var bounds =[]
	
	for x in range(bound_one[0], bound_two[0]):
		for y in range(bound_one[1], bound_two[1]):
			bounds.append([x,y])
	#propagated through to unit --> map --> level
	for type_viable in types_viable:
		emit_signal("determine_viable", type_viable, self, bounds)
	

func has_viable_placements():
	if len(viable_squares) > 0 && cooldown_progress == cooldown: return true
	else: return false

func summon_skeleton(color, square_location):
	#print("SUMMONING SKELETON")
	if cooldown_progress == cooldown:
		#propagated through to unit --> map --> level
		emit_signal("summon_unit", color, "skeleton", square_location, {"ai_type":"generic"})
		cooldown_progress = 0

func check_cooldown():
	return cooldown - cooldown_progress

func increment_cooldown():
	cooldown_progress += 0.5
	if cooldown_progress > cooldown:
		cooldown_progress = cooldown		
