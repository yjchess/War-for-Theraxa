extends Level

func _init():
	player_troops =   [unit("peasant", [0,10]), unit("peasant", [3,9])]
	computer_troops = [unit("necromancer", [0,0], 1), unit("skeleton_warrior", [1,1], 3), unit("skeleton_warrior", [0,1],3), unit("skeleton_archer",[1,0],1), unit("goblin_slave", [3,1],3)]
	player_buildings = [["outpost",[8,7]],["barracks",[8,10]],["archery_range",[9,10]],["stables",[10,10]], ["gold_mine",[1,10]],["gold_mine",[2,10]],["farm",[1,9]],["farm",[2,9]]]
	computer_buildings = [[]]
	neutral_buildings = [["grave", [1,4]],["grave", [3,5]],["grave", [3,0]],["grave", [5,3]], ["grave", [10,1]],["forest",[0,4]],["forest",[0,5]],["forest",[0,6]],["forest",[0,7]],["forest",[1,5]],["forest",[1,6]],["forest",[1,7]],["forest",[2,6]],["forest",[2,7]],["forest",[3,6]],["forest",[3,7]], ["forest",[3,8]], ["forest",[4,6]],["forest",[4,7]], ["forest",[4,8]], ["forest",[4,9]], ["forest",[5,6]],["forest",[5,7]], ["forest",[5,8]], ["forest",[7,4]],["forest",[7,5]],["forest",[7,7]],["forest",[8,6]],["forest",[8,4]],["forest",[9,7]],["forest",[9,4]],["forest",[9,3]],["forest",[10,7]],["forest",[10,8]],["forest",[10,3]],["house",[10,4]], ["forest",[11,3]]]
	neutral_units = [unit("old_man", [11,4], 5)]

func level_specifics():
	if turn == 3:
		turn = 1
		reset_player_moves()
		
	if turn == 2 && ai.game_over == false:
		print("Computer Turn")
		reset_computer_moves()
		ai.turn(computer_units.call(), player_units.call(), turns_played)
		end_turn()
