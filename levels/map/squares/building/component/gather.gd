class_name Gather
extends Node2D

var phase:int = 0
var max_phase:int
var has_phases: bool
var phases: Dictionary
var gatherable_resources: Dictionary
@onready var building = get_parent()
@onready var building_stats:Gatherable_Building_Stats = building.building_stats
@onready var building_color = building.building_color
signal gathered_resources(Dictionary)

func _ready():
	has_phases = building_stats.has_phases
	phases = building_stats.phases.duplicate(true)
	gatherable_resources = building_stats.gatherable_resources.duplicate(true)
	max_phase = building_stats.max_phase

func advance_phase():
	if has_phases:
		#1. perform the specifics of the current phase
		phase_specifics()
		if phase < max_phase: phase += 1
		elif phase == max_phase: phase = 0
			
		update_images()

func phase_specifics():
	var specific_phase = phases[phase]
	gatherable_resources = specific_phase.gatherable_resources
	gather_resources()

func update_images():
	var specific_phase = phases[phase]
	building.building_portrait = building_stats.base_path + building_color + "/" + building_color+ "_" + specific_phase.phase_sprite
	building.sprite.texture = load(building.building_portrait)	

func gather_resources():
	gathered_resources.emit(gatherable_resources)
