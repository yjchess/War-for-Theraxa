class_name Unit extends Node2D
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
var built = false
var player
var description
var kills = 0

var abilities = []
var ability_node = preload("res://levels/map/squares/unit/ability/ability.tscn")
@onready var abilities_holder = $Abilities_Holder
@onready var square = get_parent()
@onready var sprite = $AnimatedSprite2D
var x_max
var y_max

var movement_behaviour_id
var ai:AI
var ai_vars:Dictionary
signal update_minimap
signal determine_viable_squares
signal summon_unit
signal player_unit_lost
signal determine_potential_enemies

var unit_stats:Resource

func _ready():
	if ai != null: connect_ai_determine_potential_enemies_signal()
	map = get_parent().get_parent().get_parent()
	load_unit_animations()
	
	x_max = 12
	y_max = 12
	
	match unit_color:
		"red":  add_to_group("computer_unit"); player = "computer"
		"blue": add_to_group("player_unit"); player = "player"
		_: player = "neutral"
	
	
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
			unit_portrait  = "res://assets/portraits/skeleton_warrior.png"
			description    = "Though scary, skeletons are notoriously weak. That being said, they often travel in packs and overwhelm enemies"
		
		"goblin_slave":
			movement_range = 4
			health = 1
			melee_damage = 1
			ranged_damage = 0
			attack_range = 1
			unit_portrait = "res://assets/portraits/goblin_slave.png"
			description = "Goblins: considered an inferior species by the undead, serve as the scouting cannon fodder of the undead. They are fast but weak and not worth turning into an undead minion. Instead they are used to find burial sites, and perform tasks that require speed (a characteristic not usually owned by the undead)"
		
		"skeleton_warrior":
			movement_range = 1
			health         = 3
			melee_damage   = 3
			ranged_damage  = 0
			attack_range   = 1
			unit_portrait  = "res://assets/portraits/skeleton_warrior.png"
			description    = "Though scary, skeletons are notoriously weak. That being said, they often travel in packs and overwhelm enemies"

		"skeleton_archer":
			movement_range = 1
			health         = 3
			melee_damage   = 1
			ranged_damage  = 3
			attack_range   = 3
			unit_portrait  = "res://assets/portraits/skeleton_archer.png"
			description    = "Though scary, skeletons are notoriously weak. That being said, they often travel in packs and overwhelm enemies"

		"necromancer":
			movement_range = 2
			health         = 3
			melee_damage   = 1
			ranged_damage  = 3
			attack_range   = 3
			abilities      = ["summon_ghoul"]
			unit_portrait  = "res://assets/portraits/necromancer.png"
			description    = "Wizards past the point of no return. Once a wizard has meddled with the dark arts enough, their minds and bodies oft become corrupted and begin to resemble the undead creatures of which they reign over."

		"old_man":
			movement_range = 1
			health         = 3
			melee_damage   = 1
			ranged_damage  = 0
			attack_range   = 0
			unit_portrait  = "res://assets/portraits/old_man.png"
			description    = "An old man too stubborn to evacuate his house"

	max_health = health
	unit_position = [square.x_coord, square.y_coord]
	
	var common_abilities = ["movement", "attack"]
	var common_abilities_optional = ["ranged_attack", "build", "gather"]
	
	if len(abilities) > 0:
		for ability in abilities:
			instantiate_ability(ability)
	
	for ability in common_abilities:
		abilities.append(ability)
	
	if attack_range > 1:
		abilities.append(common_abilities_optional[0])
	
	if unit_name == "peasant":
		abilities.append(common_abilities_optional[1])
		abilities.append(common_abilities_optional[2])	

	#apply player upgrades
	if unit_color == "blue":
		apply_upgrades()

func determine_potential_enemies_signal(entity, potential_moves):
	emit_signal("determine_potential_enemies", entity, potential_moves)

func get_unit_possible_moves():
	var possible_squares = []
	if moved == false:
		for x in range(unit_position[0] - movement_range, unit_position[0] + movement_range+1):
			for y in range(unit_position[1] - movement_range, unit_position[1] + movement_range+1):
				possible_squares.append([x,y])
		return validate_possible_moves(possible_squares)
	
	else:
		return []

func get_unit_possible_attacks():
	var possible_attacks = []
	if attacked == false:
		for x in range(unit_position[0] - attack_range, unit_position[0] + attack_range+1):
			for y in range(unit_position[1] - attack_range, unit_position[1] + attack_range + 1):
				possible_attacks.append([x,y])
		return validate_possible_attacks(possible_attacks)
	else:
		return []

func get_buildable_squares():
	if unit_name != "peasant" || built == true:
		return []
	else:
		var possible_building_locations = []
		for x in range(unit_position[0] - 1, unit_position[0] + 2):
			for y in range(unit_position[1] - 1, unit_position[1] + 2):
				possible_building_locations.append([x,y])
		
		return validate_possible_moves(possible_building_locations)

func get_unit_possible_melee_attacks():
	var possible_attacks = []
	if attacked == false && attack_range >= 1:
		for x in range(unit_position[0] - 1, unit_position[0] + 2):
			for y in range(unit_position[1] - 1, unit_position[1] + 2):
				possible_attacks.append([x,y])
		return validate_possible_attacks(possible_attacks)
	else:
		return []

func get_unit_possible_ranged_attacks():
	var all_possible_attacks = get_unit_possible_attacks()
	var all_possible_melee_attacks = get_unit_possible_melee_attacks()
	var all_possible_ranged_attacks = []

	for attack in all_possible_attacks:
		if attack not in all_possible_melee_attacks:
			all_possible_ranged_attacks.append(attack)
	return all_possible_ranged_attacks
	
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
	tree_exited.connect(signal_death)
	queue_free()
	

#the following uses the tree_exited signal
func signal_death():
	emit_signal("update_minimap")
	if unit_color == "blue":
		emit_signal("player_unit_lost")

func use_ability(ability_name, ability_location):
	for ability:Ability in abilities_holder.get_children():
		if ability.name == ability_name:
			ability.use_ability(ability_location)
			break
	#match ability_name:
	#	"summon_skeleton": abilities_holder.get_node("summon_skeleton").summon_skeleton(unit_color, ability_location)
		#"summon_skeleton": ability_handler.summon_skeleton(unit_color, ability_location)

func instantiate_ability(ability_name):
	if ability_name not in ["movement", "attack", "build", "gather", "ranged_attack"]:
		var instance = ability_node.instantiate()
		instance.ability_stats = load("res://Resources/abilities/"+ability_name+".tres")
		instance.ability_name = ability_name
		instance.name         = ability_name
		instance.determine_viable.connect(determine_viable)
		instance.summon_unit.connect(summon_unit_signal)
		abilities_holder.add_child(instance)

func determine_viable(type_viable, entity, bounds):
	#propagated through to map --> level
	emit_signal("determine_viable_squares", type_viable, entity, bounds)

func summon_unit_signal(colour, unit, unit_position, ai_movement_behaviour):
	#propagated through to map --> level
	emit_signal("summon_unit", colour, unit, unit_position, ai_movement_behaviour)
	
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

func can_build(building, resources):
	match building:
		"farm": if resources.food >= 50: return true
		"outpost": if resources.food >= 10 && resources.gold >= 10: return true

func connect_ai_determine_potential_enemies_signal():
	ai.determine_potential_enemies.connect(determine_potential_enemies_signal)
