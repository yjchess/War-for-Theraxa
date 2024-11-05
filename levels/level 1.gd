extends Node2D
@onready var map = $Generic_Map
var player_troops =   [["villager", [10,10]]]
var computer_troops = [["villager", [1,1]]]
# Called when the node enters the scene tree for the first time.
func _ready():
	map.setup_board(player_troops, computer_troops)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
