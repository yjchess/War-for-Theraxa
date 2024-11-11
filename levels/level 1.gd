extends Node2D
@onready var map = $Generic_Map
@onready var ui = $CanvasLayer
var player_troops =   [["warrior", [1,10]],["warrior", [2,10]], ["archer", [1,11]],["archer", [2,11]], ["warrior", [9,10]],["warrior", [10,10]], ["archer", [9,11]],["archer", [10,11]]]
var computer_troops = [["warrior", [1,1], 3], ["warrior", [2,1], 3], ["cavalry_warrior", [1,0], 1], ["warrior", [9,1],3], ["warrior", [10,1],3], ["cavalry_warrior", [10,0],2]]
# Called when the node enters the scene tree for the first time.
func _ready():
	map.setup_board(player_troops, computer_troops)
	GameData.ui = ui
	GameData.update_minimap()
	GameData.connect_button()
	GameData.map = map

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
