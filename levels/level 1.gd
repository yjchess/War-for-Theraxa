extends Level

func _init():
	player_troops = [unit("warrior", [1,10]), unit("warrior",[2,10]), unit("archer",[1,11]), unit("archer",[2,11]), unit("warrior",[9,10]), unit("warrior",[10,10]), unit("archer",[9,11]), unit("archer",[10,11])]
	computer_troops = [unit("warrior", [1,1], 3), unit("warrior", [2,1],3), unit("cavalry_warrior",[1,0],1), unit("warrior", [9,1],3), unit("warrior", [10,1],3), unit("cavalry_warrior", [10,0],2)]



#@export var player_troops =   [["peasant", [1,10]],["warrior", [2,10]], ["archer", [1,11]],["archer", [2,11]], ["warrior", [9,10]],["warrior", [10,10]], ["archer", [9,11]],["archer", [10,11]]]
#var computer_troops = [["warrior", [1,1], 3], ["warrior", [2,1], 3], ["cavalry_warrior", [1,0], 1], ["warrior", [9,1],3], ["warrior", [10,1],3], ["cavalry_warrior", [10,0],2]]
