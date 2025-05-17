class_name Gatherable_Building_Stats
extends Building_Stats

@export var has_phases: bool          = true
@export var max_phase:  int           = 2

@export var phases: Dictionary= {
	0:{"gatherable_resources" :{"food":0, "gold":0}, "phase_sprite": "farm.png"},
	1:{"gatherable_resources" :{"food":0, "gold":0}, "phase_sprite": "farm_seeded.png"},
	2:{"gatherable_resources" :{"food":10, "gold":0}, "phase_sprite": "farm_cropped.png"}
	}

@export var gatherable_resources      = {"food":0, "gold":0}
