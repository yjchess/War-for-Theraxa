extends VBoxContainer

@export var id:int
@export var icon_name:String
@onready var upgrade_icon = $%Upgrade_Icon
@onready var upgrade_gems = $%Upgrade_Gems
@export var selected:bool = false

var upgraded = 0

var disabled_gem = load("res://assets/icons/achievements/achievement_gem_disabled.png")
var gold_gem     = load("res://assets/icons/achievements/achievement_gem.png")
var blue_gem     = load("res://assets/icons/achievements/achievement_gem_special.png")

@onready var stylebox_one = $PanelContainer.get_theme_stylebox("panel")
@onready var stylebox_two = $PanelContainer2.get_theme_stylebox("panel")

@export var upgrade_description_one  :String
@export var upgrade_description_two  :String
@export var upgrade_description_three:String
@export var upgrade_description_four :String
@export var upgrade_description_five :String
var upgrade_descriptions = []
var icon_image
signal display_upgrade(upgrade_descriptions, gems, portrait)

# Called when the node enters the scene tree for the first time.
func _ready():
	upgrade_descriptions = [upgrade_description_one, upgrade_description_two, upgrade_description_three, upgrade_description_four, upgrade_description_five]
	icon_image = load("res://assets/portraits/"+icon_name+".png")
	upgrade_icon.texture = icon_image
	
	build_upgrades()
	
	if selected:
		get_tree().call_group("selected","deselect")
		add_to_group("selected")
		display_upgrade.emit(upgrade_descriptions, get_gems(), icon_image, icon_name)
		stylebox_one.border_color = "GOLDENROD"
		stylebox_two.border_color = "GOLDENROD"

func add_upgrade():
	if upgraded == 5: return
	if upgraded   <  3 && GameData.available_gold_gems == 0: return
	elif upgraded >= 3 && GameData.available_blue_gems == 0: return
	
	if upgraded < 3:
		upgrade_gems.get_child(upgraded).texture = gold_gem
		GameData.common_upgrades[id][0] += 1
	else:
		upgrade_gems.get_child(upgraded).texture = blue_gem
		GameData.common_upgrades[id][1] += 1
	
	upgraded += 1
	GameData.calculate_available_gems()
	display_upgrade.emit(upgrade_descriptions, get_gems(), icon_image, icon_name)
	
func remove_upgrade():
	if upgraded == 0: return
	upgrade_gems.get_child(upgraded-1).texture = disabled_gem
	upgraded -= 1
	
	if upgraded > 2:
		GameData.common_upgrades[id][1] -= 1
	else:
		GameData.common_upgrades[id][0] -= 1
		
	GameData.calculate_available_gems()
	display_upgrade.emit(upgrade_descriptions, get_gems(), icon_image, icon_name)

func build_upgrades():
	var upgrades = GameData.common_upgrades[id]
	var gold = upgrades[0]
	var blue = upgrades[1]
	
	for i in range(0,gold):
		upgrade_gems.get_child(i).texture = gold_gem
		upgraded+=1
	
	for i in range(3, blue+3):
		upgrade_gems.get_child(i).texture = blue_gem
	


func _on_area_2d_mouse_entered():
	if !selected:
		stylebox_one.border_color = "MEDIUM_AQUAMARINE"
		stylebox_two.border_color = "MEDIUM_AQUAMARINE"


func _on_area_2d_mouse_exited():
	if !selected:
		stylebox_one.border_color = "BLACK"
		stylebox_two.border_color = "BLACK"


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected = !selected

		if selected:
			get_tree().call_group("selected","deselect")
			add_to_group("selected")
			#var icon_image = load("res://assets/portraits/"+icon_name+".png")
			display_upgrade.emit(upgrade_descriptions, get_gems(), icon_image, icon_name)
			stylebox_one.border_color = "GOLDENROD"
			stylebox_two.border_color = "GOLDENROD"
		else:
			stylebox_one.border_color = "BLACK"
			stylebox_two.border_color = "BLACK"

func deselect():
	remove_from_group("selected")
	selected = false
	stylebox_one.border_color = "BLACK"
	stylebox_two.border_color = "BLACK"


func get_gems():
	var gem_textures = []
	for gem in %Upgrade_Gems.get_children():
		gem_textures.append(gem.texture)
	return gem_textures
