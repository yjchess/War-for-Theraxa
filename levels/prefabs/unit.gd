extends Node2D
var unit_name
var unit_color
var unit_position
var unit_portrait
var map

var max_health
var unit_selected
var movement_range = 1
var health
var melee_damage
var ranged_damage = 0
var attack_range
var moved = false
var attacked = false
var player
var description
var kills = 0

var abilities = []
var ability_node = preload("res://levels/prefabs/ability.tscn")
@onready var abilities_holder = $Abilities_Holder
@onready var square = get_parent()

var x_max
var y_max

var movement_behaviour_id
signal update_minimap

func _ready():
	map = get_parent().get_parent().get_parent()
	load_unit_animations()
	
	x_max = 12
	y_max = 12
	
	if unit_color == "red":
		add_to_group("computer_unit") 
		player = "computer"
	elif unit_color == "blue":
		add_to_group("player_unit")  
		player = "player"
	else: player = "neutral"
	
	match unit_name:
		"peasant":
			movement_range = 2
			health         = 3
			melee_damage   = 1
			attack_range   = 1
			unit_portrait  = "res://assets/portraits/archer.png"
			description    = "The uniniitiated conscript."
		
		"warrior": 
			movement_range = 2
			health         = 7
			melee_damage   = 3
			attack_range   = 1
			unit_portrait  = "res://assets/portraits/warrior.png"
			description    = "The bread and butter of your army. A stable, well armoured melee unit. Useful as a meatshield or to overwhelm enemies in numbers."
			
		"archer": 
			movement_range = 2
			health         = 6
			melee_damage   = 1
			ranged_damage  = 4
			attack_range   = 3
			unit_portrait  = "res://assets/portraits/archer.png"
			description    = "The archer is a simple ranged unit. They are capable of taking down enemies from afar, but beware their vulnerable health."
		
		"cavalry_warrior": 
			movement_range = 3
			health         = 15
			melee_damage   = 5
			attack_range   = 1
			unit_portrait  = "res://assets/portraits/warrior.png"
			description    = "The cavalry warrior is a mighty beast. They stride quickly into battle with mobile maneuvers and deep strikes"
	
		"wizard": 
			movement_range = 1
			health         = 3
			melee_damage   = 1
			ranged_damage  = 6
			attack_range   = 2
			abilities      = ["summon_skeleton"]
			unit_portrait  = "res://assets/portraits/wizard.png"
			description    = "The wizard is a vital piece of any army, capable of casting powerful spells and turning the tides of battle."
			
		"skeleton":
			movement_range = 1
			health         = 3
			melee_damage   = 3
			ranged_damage  = 0
			attack_range   = 1
			unit_portrait  = "res://assets/portraits/wizard.png"
			description    = "Though scary, skeletons are notoriously weak. That being said, they often travel in packs and overwhelm enemies"
	
	max_health = health
	unit_position = [square.x_coord, square.y_coord]
	
	if len(abilities) > 0:
		for ability in abilities:
			instantiate_ability(ability)
	
	var common_abilities = ["movement", "attack", "build", "gather", "ranged_attack"]
	for ability in common_abilities:
		abilities.append(ability)
	
	#apply player upgrades
	if unit_color == "blue":
		apply_upgrades()
	
func get_unit_possible_moves():
	var possible_squares = []
	#if (player == "player" && GameData.turn == 1) || (player == "computer" && GameData.turn ==2):
	if moved == false:
		for x in range(unit_position[0] - movement_range, unit_position[0] + movement_range+1):
			for y in range(unit_position[1] - movement_range, unit_position[1] + movement_range+1):
				possible_squares.append([x,y])
		return validate_possible_moves(possible_squares)
	
	else:
		return []

func get_unit_possible_attacks():
	var possible_attacks = []
	#if (player == "player" && GameData.turn == 1) || (player == "computer" && GameData.turn ==2):
	if attacked == false:
		for x in range(unit_position[0] - attack_range, unit_position[0] + attack_range+1):
			for y in range(unit_position[1] - attack_range, unit_position[1] + attack_range + 1):
				possible_attacks.append([x,y])
		return validate_possible_attacks(possible_attacks)
	else:
		return []

func validate_possible_moves(moves):
	var validated_moves = []
	#var in_bounds = false
	#var empty_square = false
	for move in moves:
		
		if (move[0] < x_max && move[0] > -1) && (move[1] < y_max && move[1] > -1):
			if !(map.get_square(move[0], move[1]).has_unit() || map.get_square(move[0], move[1]).has_building()):
				validated_moves.append(move)

	return validated_moves

func validate_possible_attacks(moves):
	var validated_moves = []
	for move in moves:
				
		if (move[0] < x_max && move[0] > -1) && (move[1] < y_max && move[1] > -1):
			if (map.get_square(move[0], move[1]).has_enemy_unit(unit_color) || map.get_square(move[0], move[1]).has_enemy_building(unit_color)):
				validated_moves.append(move)

	return validated_moves

func move(x_coord, y_coord):
	var new_square = map.get_square(x_coord, y_coord)
	reparent(new_square, false)
	unit_position = [x_coord, y_coord]
	moved = true
	#GameData.update_minimap()
	emit_signal("update_minimap")


func attack(x_coord, y_coord):
	var damage
	attacked = true
	moved = true
	
	if x_coord in [unit_position[0]-1, unit_position[0], unit_position[0]+1] && y_coord in [unit_position[1]-1, unit_position[1], unit_position[1]+1]:
		damage = melee_damage
	else:
		damage = ranged_damage
	
	map.get_square(x_coord, y_coord).get_node_or_null("Unit").receive_attack(damage, null)

func receive_attack(damage, status_effects):
	health -= damage
	if health <= 0:
		die()
	if status_effects == null:
		pass
	
func load_unit_animations():
	var animated_sprite = load("res://levels/prefabs/animations/"+unit_color+"_"+unit_name+".tscn")
	var instance = animated_sprite.instantiate()
	add_child(instance)

func die():
	#GameData.remove_unit_from_arrays(self)
	tree_exited.connect(signal_death)
	queue_free()
	

#the following uses the tree_exited signal
func signal_death():
	emit_signal("update_minimap")
	if unit_color == "blue":
		GameData.level.lost_player_unit = true

func use_ability(ability_name, ability_location):
	match ability_name:
		"summon_skeleton": abilities_holder.get_node("summon_skeleton").summon_skeleton(unit_color, ability_location)
		#"summon_skeleton": ability_handler.summon_skeleton(unit_color, ability_location)

func instantiate_ability(ability_name):
	if ability_name not in ["movement", "attack", "build", "gather", "ranged_attack"]:
		var instance = ability_node.instantiate()
		instance.ability_name = ability_name
		instance.name         = ability_name
		abilities_holder.add_child(instance)

func apply_upgrades():
	var warrior_upgrades = GameData.common_upgrades[0]
	if unit_name == "warrior" && warrior_upgrades != [0,0]:
		if warrior_upgrades[0] >= 1:
			health     += 2
			max_health += 2
		
		if warrior_upgrades[0] >= 2:
			health     += 2
			max_health += 2
		
		if warrior_upgrades[0] >= 3:
			melee_damage +=1
		
		if warrior_upgrades[1] >= 1:
			abilities.append("Parry")
		
		if warrior_upgrades[1] >= 2:
			abilities.append("Net")
	
	var archer_upgrades = GameData.common_upgrades[1]
	if unit_name == "archer" && archer_upgrades != [0,0]:
		if archer_upgrades[0] >= 1:
			melee_damage += 1
		
		if archer_upgrades[0] >= 2:
			ranged_damage += 1
		
		if warrior_upgrades[0] >= 3:
			health += 2
			max_health += 2
		
		if warrior_upgrades[1] >= 1:
			abilities.append("Pinning Shot")
		
		if warrior_upgrades[1] >= 2:
			abilities.append("Fleet Footed")

#used before saving - as loading will rebuild the upgrades
func remove_upgrades():
	var warrior_upgrades = GameData.common_upgrades[0]
	if unit_name == "warrior" && warrior_upgrades != [0,0]:
		if warrior_upgrades[0] >= 1:
			health     -= 2
			max_health -= 2
		
		if warrior_upgrades[0] >= 2:
			health     -= 2
			max_health -= 2
		
		if warrior_upgrades[0] >= 3:
			melee_damage -=1

	
	var archer_upgrades = GameData.common_upgrades[1]
	if unit_name == "archer" && archer_upgrades != [0,0]:
		if archer_upgrades[0] >= 1:
			melee_damage -= 1
		
		if archer_upgrades[0] >= 2:
			ranged_damage -= 1
		
		if warrior_upgrades[0] >= 3:
			health -= 2
			max_health -= 2

func get_ability(ability_name):
	for ability in abilities_holder:
		if ability.name == ability_name:
			return ability
