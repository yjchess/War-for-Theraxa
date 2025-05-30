extends Level

func _init():
	player_troops =   [unit("peasant", [0,9]), unit("peasant", [3,9])]
	computer_troops = [unit("goblin_slave", [3,1],["pre_determined",[[5,2],[7,1],[8,3],[6,5],[8,5],[10,5]], true]), unit("necromancer", [2,1], ["pre_determined",[[2,1],[2,3],[4,4],[6,2],[7,2],[6,4],[8,5]],false])]
	player_buildings = [["outpost",[8,7]],["barracks",[8,10]],["archery_range",[9,10]],["stables",[10,10]], ["gold_mine",[1,10]],["gold_mine",[2,10]],["farm",[1,9]],["farm",[2,9]]]
	computer_buildings = [[]]
	neutral_buildings = [["grave", [1,4]],["grave", [3,5]],["grave", [3,0]],["grave", [5,3]], ["grave", [8,1]],["house",[10,4]]]
	environmental_buildings = [["forest",[0,4]],["forest",[0,5]],["forest",[0,6]],["forest",[0,7]],["forest",[1,5]],["forest",[1,6]],["forest",[1,7]],["forest",[2,6]],["forest",[2,7]],["forest",[3,6]],["forest",[3,7]], ["forest",[3,8]], ["forest",[4,6]],["forest",[4,7]], ["forest",[4,8]], ["forest",[4,9]], ["forest",[5,6]],["forest",[5,7]], ["forest",[5,8]], ["forest",[7,4]],["forest",[7,5]],["forest",[7,7]],["forest",[8,6]],["forest",[8,4]],["forest",[9,7]],["forest",[9,4]],["forest",[9,3]],["forest",[10,7]],["forest",[10,8]],["forest",[10,3]], ["forest",[11,3]]]
	neutral_units = [unit("old_man", [11,4], ["generic"])]

func level_specifics():
	super()
	if turns_played == 2:
		dialogue.new_dialogue()
	
	if turns_played == 5 and is_alive("goblin_slave"):
		dialogue.play_optional_dialogue("Grinkle_finds_old_man")
	
	if turns_played == 6 and is_alive("old_man") and is_alive("goblin_slave") and is_alive("necromancer"):
		var grinkle = get_unit("goblin_slave")
		grinkle.attack(11,4)
		dialogue.play_optional_dialogue("Grinkle_kills_old_man")
	


func evaluate_achievements():
	pass

#The following function is for level specific units
func is_alive(unit_name):
	for unit in computer_units.call():
		if unit.unit_name == unit_name:
			return true
	
	for unit in neutral_units:
		if unit.unit_name == unit_name:
			return true
			
	return false

func get_unit(unit_name):
	for unit in computer_units.call():
		if unit.unit_name == unit_name:
			return unit
