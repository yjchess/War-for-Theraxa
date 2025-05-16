extends Node2D
class_name ACHIEVEMENT_HANDLER

signal submit_ui_update (StringName, Variant)
@onready var achievements_node:ACHIEVEMENTS = $Achievements

func _set(name, value) -> bool:
	match name:
		"achievements", "special_achievements", "super_special_achievements": 
			submit_ui_update.emit.call_deferred(name, value)
  	
	return false
