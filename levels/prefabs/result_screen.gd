extends Control
var achievement = preload("res://levels/prefabs/achievement.tscn")


func populate_achievements(achievements):
	for achievement in achievements:
		create_achievement("normal", achievement[0], achievement[1])

func populate_special_achievements(achievements):
	for achievement in achievements:
		create_achievement("special", achievement[0], achievement[1])


func create_achievement(type, tooltip, display):
	var instance = achievement.instantiate()
	instance.tooltip_text = tooltip
	
	if type == "normal":
		$%Achievements.add_child(instance)
	else:
		instance.special = true
		$%Special_Achievements.add_child(instance)
	
	if display == true:
		instance.achieved = true


func _on_redo_pressed():
	print("RELOAD")
	get_tree().reload_current_scene()
	pass # Replace with function body.
