class_name Train
extends Node2D

var phase:int = 0
var max_phase:int
var has_phases: bool
var phases: Dictionary
var training_costs: Array
@onready var building: Building = get_parent()
@onready var building_stats:Trainable_Building_Stats = building.building_stats.duplicate(true)
@onready var building_color = building.building_color
signal submit_level_update(StringName, Variant)

func _ready():
	name = "train_component"
	training_costs = building_stats.costs.duplicate(true)

func train(train_name):
	print("TRAINING: ",train_name)
	var player = building.player
	for training_cost in training_costs:
		if "train_"+training_cost["unit"] == train_name:
			print(training_cost)
			if has_enough_resources(player):
				submit_level_update.emit(player+"_resources", {"food": -training_cost["food"], "gold": -training_cost["gold"]})
				return true
			else:
				return false

func has_enough_resources(player):
	return true
