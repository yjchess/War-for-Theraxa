extends Node2D
class_name ACHIEVEMENTS
signal submit_ui_update (StringName, Variant)


@export var achievements = [["Beat the level",false], ["Don't let enemy troops call for reinforcements",false], ["Win without losing a single troop", false]]
@export var special_achievements = [["Beat the level after letting reinforcements come", false], ["Let reinforcements arrive and beat them without losing a unit", false]]
@export var super_special_achievements = [["Beat reinforments, don't use campaign upgrades, have 2+ units at the end", false]]

func _enter_tree() -> void:
	submit_ui_update.emit("achievements", {"achievements":achievements, "special_achievements": special_achievements, "super_special_achievements": super_special_achievements})

func _set(name, value) -> bool:
	match name:
		"achievements", "special_achievements", "super_special_achievements": 
			submit_ui_update.emit.call_deferred(name, value)
  	
	return false
