extends Control

const REGISTRY = {
	castle = "res://campaign/campaign_map/castle/castle.tscn",
	level_one = "res://levels/Level 1.tscn",
	level_two = "res://levels/Level 2.tscn"
}

func _on_level_change(level):
	var level_path = "res://levels/"+level+".tscn"
	if validate_scene(level_path):
		get_tree().change_scene_to_file(level_path)

	

func _on_castle_button_pressed():
	var castle_path = "res://campaign/campaign_map/castle/castle.tscn"
	if validate_scene(castle_path):
		get_tree().change_scene_to_file(castle_path)
	
func validate_scene(scene) -> bool:
	if scene in REGISTRY.values(): return true
	else: return false
	
