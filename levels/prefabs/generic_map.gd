extends Node2D
@export var width: int
@export var height: int
@onready var squares = $Squares
#@onready var units = $Units
var viewport_width = 1920
var viewport_height = 1080
var square_width = 64
var square_height = 64
var square = preload("res://levels/prefabs/square.tscn")
var unit   = preload("res://levels/prefabs/unit.tscn")
var starting_square_location

@onready var ai = $"../AI"
var computer_units = []
var player_units = []
# Called when the node enters the scene tree for the first time.
func _ready():
	#as the following is using integer divide, viewport_width / square_width = viewport_width 
	GameData.map = self
	GameData.map_height = height
	GameData.map_width = width
	GameData.ai = ai
	
	var starting_square_x = ((viewport_width / square_width) * square_width - square_width * width) / 2
	var starting_square_y = ((viewport_height / square_height) * square_height - square_height * height) / 2
	starting_square_location = [starting_square_x, starting_square_y] 
	GameData.starting_square_position = starting_square_location
	
	for y in height:
		for x in width:
		
			instantiate_square(x,y)
	
	GameData.squares = squares.get_children()
	
func setup_board(player_pieces, computer_pieces):
	for piece in player_pieces:
		var color = "blue"
		var unit = piece[0]
		var unit_position = piece[1]
		place_piece(color, unit, unit_position, null)
	
	for piece in computer_pieces:
		var color                 = "red"
		var unit                  = piece[0]
		var unit_position         = piece[1]
		var ai_movement_behaviour = piece[2]
		place_piece(color, unit, unit_position, ai_movement_behaviour)
	
	GameData.computer_units = computer_units
	GameData.player_units = player_units
	
func place_piece(colour, unit, unit_position, ai_movement_behaviour):
	instantiate_unit(colour, unit, unit_position, ai_movement_behaviour)
	GameData.update_minimap()

func instantiate_unit(colour, name, position, movement_id):
	var instance           = unit.instantiate()
	instance.unit_color    = colour
	instance.unit_name     = name
	instance.unit_position = position
	instance.movement_behaviour_id = movement_id

	#instance.place_unit()
	var square_parent = get_square(position[0], position[1])
	square_parent.add_child(instance)
	if instance.unit_color == "red":
		computer_units.append(instance)
	else:
		player_units.append(instance)
	#units.add_child(instance)

func instantiate_unit_detailed(colour, name, position, movement_id, health, max_health, moved, attacked):
	var instance                   = unit.instantiate()
	instance.unit_color            = colour
	instance.unit_name             = name
	instance.unit_position         = position
	instance.movement_behaviour_id = movement_id
	instance.health                = health
	instance.max_health            = max_health
	instance.moved                 = moved
	instance.attacked              = attacked

	#instance.place_unit()
	var square_parent = get_square(position[0], position[1])
	square_parent.add_child(instance)
	if instance.unit_color == "red":
		computer_units.append(instance)
	else:
		player_units.append(instance)

func instantiate_square(x,y):
	var instance        = square.instantiate()
	instance.x_coord    = x
	instance.y_coord    = y
	instance.x_max      = width
	instance.y_max      = height
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
	get_tree().call_group("movable_square_UI", "hide")
	get_tree().call_group("attackable_square_UI", "hide")
	var previous_selected_square          = GameData.selected_square
	if previous_selected_square != null:
		var previous_selected_square_instance = get_square(previous_selected_square[0], previous_selected_square[1])
		previous_selected_square_instance.deselect()

func update_minimap_squares():
	GameData.squares = squares.get_children()

func place_serialized_units(playerUnits, computerUnits):
	for unit in playerUnits:
		instantiate_unit_detailed("blue", unit.unit_name, unit.unit_position, unit.unit_movement_behaviour_id, unit.unit_health, unit.unit_max_health, unit.unit_moved, unit.unit_attacked)
		
	for unit in computerUnits:
		instantiate_unit_detailed("red", unit.unit_name, unit.unit_position, unit.unit_movement_behaviour_id, unit.unit_health, unit.unit_max_health, unit.unit_moved, unit.unit_attacked)
	
	GameData.computer_units = computer_units
	GameData.player_units = player_units
	GameData.update_minimap()
