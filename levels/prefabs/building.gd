extends Node2D
var building_name
var building_color
var building_position
var building_portrait

@onready var sprite = $Sprite2D

var map

var max_health
var unit_selected
var health
var moved = false
var attacked = false
var player
var description

var abilities = []
var ability_node = preload("res://levels/prefabs/ability.tscn")
@onready var abilities_holder = $Abilities_Holder
@onready var square = get_parent()

var x_max
var y_max

var movement_behaviour_id

func _ready():
	map = get_parent().get_parent().get_parent()
	#load_building_animations()
	
	x_max = GameData.map_width
	y_max = GameData.map_height
	
	if building_color == "red": 
		player = "computer"
	elif building_color == "blue": 
		player = "player"
	elif building_color == "dark_green": 
		player = "neutral"
	else:
		player = "none"
	
	match building_name:
		"barracks":
			health             = 15
			building_portrait  = "res://assets/blue_barracks.png"
			description        = "The training facility for melee soldiers."
			sprite.texture     = load("res://assets/"+building_color+"_"+building_name+".png")
			sprite.scale       = Vector2(0.5, 0.5)
			abilities          = ["train_warrior"]

		"archery_range":
			health             = 15
			building_portrait  = "res://assets/blue_archery_range.png"
			description        = "The training facility for ranged units."
			sprite.texture     = load("res://assets/"+building_color+"_"+building_name+".png")
			sprite.scale       = Vector2(0.5, 0.5)
			abilities          = ["train_archer"]
		
		"stables":
			health             = 15
			building_portrait  = "res://assets/blue_stables.png"
			description        = "The training facility for mounted units."
			sprite.texture     = load("res://assets/"+building_color+"_"+building_name+".png")
			sprite.scale       = Vector2(0.5, 0.5)
			abilities          = ["train_cavalry_warrior"]
			
		"forest":
			health            = 1
			building_portrait = "res://assets/Tree.png"
			description       = "I don't know what to put here, it's just the forest?"
			sprite.texture    = load("res://assets/Tree.png")
			sprite.scale      = Vector2(1,1)
			sprite.offset     = Vector2(32,32)
		
		"outpost":
			health            = 20
			building_portrait = "res://assets/outpost.png"
			description       = "Provides vision over a certain area"
			sprite.texture    = load("res://assets/"+building_color+"_"+building_name+".png")
			sprite.scale      = Vector2(1,1)
			sprite.offset     = Vector2(32,32)
		
		"gold_mine":
			health            = 30
			building_portrait = "res://assets/gold_mine.png"
			description       = "Allows peasants to mine gold"
			sprite.texture    = load("res://assets/"+building_color+"_"+building_name+".png")
			sprite.scale      = Vector2(1,1)
			sprite.offset     = Vector2(32,32)
		
		"farm":
			health            = 15
			building_portrait = "res://assets/farm.png"
			description       = "Farmland that produces food for soldiers"
			sprite.texture    = load("res://assets/"+building_color+"_"+building_name+".png")
			sprite.scale      = Vector2(1,1)
			sprite.offset     = Vector2(32,32)

	max_health = health
	building_position = [square.x_coord, square.y_coord]
	
	if len(abilities) > 0:
		for ability in abilities:
			instantiate_ability(ability)
	
	#apply player upgrades
	if building_color == "blue":
		apply_upgrades()
	
func receive_attack(damage, status_effects):
	health -= damage
	if health <= 0:
		die()
	if status_effects == null:
		pass
	
func load_building_animations():
	var animated_sprite = load("res://levels/prefabs/animations/"+building_color+"_"+building_name+".tscn")
	#var animated_sprite = load("res://levels/prefabs/animations/"+building_color+"_"+building_name+".tscn")
	var instance = animated_sprite.instantiate()
	add_child(instance)

func die():
	GameData.remove_unit_from_buildings(self)
	tree_exited.connect(signal_death)
	queue_free()
	

#the following uses the tree_exited signal
func signal_death():
	GameData.update_minimap()
	if building_color == "blue":
		GameData.level.lost_player_building = true


func instantiate_ability(ability_name):
	var instance = ability_node.instantiate()
	instance.ability_name = ability_name
	instance.name         = ability_name
	abilities_holder.add_child(instance)

func apply_upgrades():
	pass

#used before saving - as loading will rebuild the upgrades
func remove_upgrades():
	pass
