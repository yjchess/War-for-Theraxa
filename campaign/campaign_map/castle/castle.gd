extends Control
@onready var upgrades = %upgrades

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.calculate_total_gems()
	GameData.calculate_available_gems()
	%"Gold Gems".text   = str(GameData.available_gold_gems)   + "/" + str(GameData.total_gold_gems)
	%"Blue Gems".text   = str(GameData.available_blue_gems)   + "/" + str(GameData.total_blue_gems)
	%"Purple Gems".text = str(GameData.available_purple_gems) + "/" + str(GameData.available_purple_gems)
	
	for upgrade in upgrades.get_children():
		upgrade.display_upgrade.connect(show_upgrade_options)


func _on_map_button_pressed():
	get_tree().change_scene_to_file("res://menus/campaign_map.tscn")
	pass # Replace with function body.

func show_upgrade_options(upgrade_descriptions, gems, portrait, unit_name):
	GameData.calculate_total_gems()
	GameData.calculate_available_gems()
	%"Gold Gems".text   = str(GameData.available_gold_gems)   + "/" + str(GameData.total_gold_gems)
	%"Blue Gems".text   = str(GameData.available_blue_gems)   + "/" + str(GameData.total_blue_gems)
	%"Purple Gems".text = str(GameData.available_purple_gems) + "/" + str(GameData.available_purple_gems)
	
	
	var count = 0
	for panel_container in %Descriptions.get_children():
		panel_container.get_child(0).text = upgrade_descriptions[count]
		count += 1
	
	count = 0 
	for gem in %Gems.get_children():
		gem.texture = gems[count]
		count += 1
		
	%Portrait.texture = portrait
	%Name.text = "  "+unit_name.capitalize()


func _on_downgrade_pressed():
	get_tree().call_group("selected","remove_upgrade")


func _on_upgrade_pressed():
	get_tree().call_group("selected","add_upgrade")
