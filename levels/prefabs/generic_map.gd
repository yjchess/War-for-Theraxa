extends Node2D
@export var width: int
@export var height: int
@onready var squares = $Squares
var viewport_width = 1920
var viewport_height = 1080
var square_width = 64
var square_height = 64
var square = preload("res://levels/prefabs/square.tscn")
var unit   = preload("res://levels/prefabs/unit.tscn")
var starting_square_location

# Called when the node enters the scene tree for the first time.
func _ready():
	#as the following is using integer divide, viewport_width / square_width = viewport_width 
	var starting_square_x = ((viewport_width / square_width) * square_width - square_width * width) / 2
	var starting_square_y = ((viewport_height / square_height) * square_height - square_height * height) / 2
	starting_square_location = [starting_square_x, starting_square_y] 
	
	for x in width:
		for y in height:
			instantiate_square(x,y)
	
func setup_board(player_pieces, computer_pieces):
	for piece in player_pieces:
		var color = "blue"
		var unit = piece[0]
		var unit_position = piece[1]
		place_piece(color, unit, unit_position)
	
	for piece in computer_pieces:
		var color         = "red"
		var unit          = piece[0]
		var unit_position = piece[1]
		place_piece(color, unit, unit_position)
	
func place_piece(color, unit, unit_position):
	instantiate_unit(color, name, position)

func instantiate_unit(color, name, position):
	pass
	
func instantiate_square(x,y):
	var instance        = square.instantiate()
	instance.x_coord    = x
	instance.y_coord    = y
	instance.position.x = starting_square_location[0] + x*64
	instance.position.y = starting_square_location[1] + y*64
	instance.override_square_selected.connect(remove_previous_selected_square)
	squares.add_child(instance)
	pass

func get_square(x,y):
	for square_instance in squares.get_children():
		if square_instance.x_coord == x && square_instance.y_coord == y:
			return square_instance

func remove_previous_selected_square():
	var previous_selected_square          = GameData.selected_square
	var previous_selected_square_instance = get_square(previous_selected_square[0], previous_selected_square[1])
	previous_selected_square_instance.deselect()
	