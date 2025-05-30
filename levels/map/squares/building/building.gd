extends Node2D
class_name Building

var building_name
var building_color
var building_position
var building_portrait

@onready var sprite = $Sprite2D
var building_stats: Resource

var map

var max_health
var unit_selected
var health
var moved = false
var attacked = false
var built = false
var player
var description
var building_types

var abilities = []
var ability_node = preload("res://levels/map/squares/unit/ability/ability.tscn")
@onready var abilities_holder = $Abilities_Holder
@onready var square = get_parent()

var x_max
var y_max

var movement_behaviour_id
signal summon_unit

func _ready():
	map = get_parent().get_parent().get_parent()
	#load_building_animations()
	
	x_max = 12
	y_max = 12

	
	match building_color:
		"red":         player = "computer"
		"blue":        player = "player"
		"neutral":     player = "neutral"
		"environment": player = "environment"
		_:             player = "none"
	
	health = building_stats.health
	building_portrait = building_stats.base_path + building_color + "/" + building_color+ "_" + building_name + ".png"
	description = building_stats.description
	sprite.texture = load(building_portrait)
	sprite.scale = building_stats.sprite_scale
	sprite.offset = building_stats.sprite_offset
	abilities = building_stats.abilities
	building_types = building_stats.building_types

	max_health = health
	building_position = [square.x_coord, square.y_coord]
	
	if building_types != [Building_Stats.Building_Type.NORMAL]:
		for building_type in building_types:
			attach_node(building_type)

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
	
#func load_building_animations():
#	var animated_sprite = load("res://levels/prefabs/animations/"+building_color+"_"+building_name+".tscn")
#	#var animated_sprite = load("res://levels/prefabs/animations/"+building_color+"_"+building_name+".tscn")
#	var instance = animated_sprite.instantiate()
#	add_child(instance)

func die():
	tree_exited.connect(signal_death)
	queue_free()
	

#the following uses the tree_exited signal
func signal_death():
	emit_signal("update_minimap")
	if building_color == "blue":
		emit_signal("player_unit_lost")


func instantiate_ability(ability_name):
	var instance = ability_node.instantiate()
	instance.ability_stats = load("res://Resources/abilities/buildings/"+ability_name+".tres")
	instance.ability_name = ability_name
	instance.name         = ability_name
	instance.summon_unit.connect(summon_unit_signal)
	abilities_holder.add_child(instance)


func get_buildable_squares():
	if built == true:
		return []
	else:
		var possible_building_locations = []
		for x in range(building_position[0] - 1, building_position[0] + 2):
			for y in range(building_position[1] - 1, building_position[1] + 2):
				possible_building_locations.append([x,y])
		
		return validate_possible_moves(possible_building_locations)

func validate_possible_moves(moves):
	var validated_moves = []
	for move in moves:
		
		if (move[0] < x_max && move[0] > -1) && (move[1] < y_max && move[1] > -1):
			if !(map.get_square(move[0], move[1]).has_unit() || map.get_square(move[0], move[1]).has_building()):
				validated_moves.append(move)

	return validated_moves

func can_build(unit, resources):
	match unit:
		"archer": if resources.food >= 50: return true
		"warrior": if resources.food >=20: return true
		"cavalry_warrior": if resources.food >= 50 and resources.gold >= 50: return true

func summon_unit_signal(colour, unit, unit_position, ai_movement_behaviour):
	#propagated through to map --> level
	emit_signal("summon_unit", colour, unit, unit_position, ai_movement_behaviour)

func apply_upgrades():
	pass

#used before saving - as loading will rebuild the upgrades
func remove_upgrades():
	pass

func attach_node(building_type):
	var node_script:String
	match building_type:
		Building_Stats.Building_Type.GATHERABLE: node_script = "gather.gd"
		Building_Stats.Building_Type.TRAINABLE: node_script = "train.gd"
	
	#var node = load("res://levels/map/squares/building/component/"+node_scene)
	#var instance = node.instantiate()
	#add_child(instance)
	var node2d = Node2D.new()
	node2d.set_script(load("res://levels/map/squares/building/component/"+node_script))
	add_child(node2d)


func use_ability(ability_name, ability_location):
	print("BUILDING: ",building_name,"using ability: ",ability_name)
	for ability:Ability in abilities_holder.get_children():
		if ability.name == ability_name:
			ability.use_ability(ability_location)
			break
