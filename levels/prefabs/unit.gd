extends Node2D
var unit_name
var unit_color
var unit_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func place_unit():
	position.x = unit_position[0]*64 + GameData.starting_square_position[0]
	position.y = unit_position[1]*64 + GameData.starting_square_position[1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
