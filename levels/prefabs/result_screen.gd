extends Control
var achievement = preload("res://levels/prefabs/achievement.tscn")


func populate_achievements(achievements):
	for achievement in achievements:
		create_achievement("normal", achievement[0], achievement[1])

func populate_special_achievements(achievements):
	for achievement in achievements:
		create_achievement("special", achievement[0], achievement[1])

func populate_super_special_achievements(achievements):
	for achievement in achievements:
		create_achievement("super_special", achievement[0], achievement[1])

func show_previously_achieved(previous_achievements):
	var count = 0
	for achievement in previous_achievements[0]:
		if achievement == true:
			$%Achievements.get_child(count).already_achieved = true
		count += 1
	
	count = 0
	for special_achievement in previous_achievements[1]:
		if special_achievement == true:
			$%Special_Achievements.get_child(count).already_achieved = true
		count += 1
	
	count = 0
	for super_special_achievement in previous_achievements[1]:
		if super_special_achievement == true:
			$%Super_Special_Achievements.get_child(count).already_achieved = true
		count += 1
			
func create_achievement(type, tooltip, display):
	var instance = achievement.instantiate()
	instance.tooltip_text = tooltip
	
	if type == "normal":
		$%Achievements.add_child(instance)
	elif type == "special":
		instance.special = true
		$%Special_Achievements.add_child(instance)
	else:
		instance.super_special = true
		$%Super_Special_Achievements.add_child(instance)
		
	
	if display == true:
		instance.achieved = true


func _on_redo_pressed():
	get_tree().reload_current_scene()


func _on_next_pressed():
	get_tree().change_scene_to_file("res://levels/castle.tscn")

func _on_map_pressed():
	get_tree().change_scene_to_file("res://menus/campaign_map.tscn")
