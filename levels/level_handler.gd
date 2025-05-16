extends Node2D
class_name LEVEL_HANDLER

var player_resources = {"food":100, "gold":100}
var computer_resources = {"food":0, "gold":0}

signal submit_ui_update (StringName, Variant)

func _enter_tree() -> void:
	emit_signal("submit_ui_update", "player_resources", player_resources)
