extends Node2D
@export var width = 12
@export var height = 12
@onready var squares = $Squares
#@onready var units = $Units
var viewport_width = 1920
var viewport_height = 1080
var square_width = 64
var square_height = 64
var square = preload("res://levels/map/squares/square.tscn")
var unit   = preload("res://levels/map/squares/unit/unit.tscn")
var building = preload("res://levels/map/squares/building/building.tscn")
var starting_square_location

@onready var ai = $"../AI"
var computer_units = []
var computer_buildings = []
var player_units = []
var player_buildings = []

signal update_minimap

signal square_selected
signal unit_selected
signal building_selected

signal unit_attack
signal unit_move
signal unit_ability

signal player_unit_lost
# Called when the node enters the scene tree for the first time.
func _ready():
	#as the following is using integer divide, viewport_width / square_width = viewport_width 
	
	var starting_square_x = ((viewport_width / square_width) * square_width - square_width * width) / 2
	var starting_square_y = ((viewport_height / square_height) * square_height - square_height * height) / 2
	starting_square_location = [starting_square_x, starting_square_y] 
	
	for y in height: for x in width: instantiate_square(x,y)
	
	
func setup_board(player_pieces, computer_pieces, player_buildings, computer_buildings, neutral_buildings, neutral_pieces):
	if player_pieces != []:
		for piece in player_pieces:
			place_piece("blue", piece.unit_name, piece.unit_location, null)
	
	if computer_pieces != []:
		for piece in computer_pieces:
			place_piece("red", piece.unit_name, piece.unit_location, piece.ai_behaviour)
	
	if player_buildings != [[]]:
		for building in player_buildings:
			#place_building (colour, name, position, ai_behaviour)
			place_building("blue",  building[0], building[1], null)
	
	if computer_buildings != [[]]:
		for building in computer_buildings:
			place_building("red", building[0], building[1], null)
			
	if neutral_buildings != [[]]:
		for building in neutral_buildings:
			place_building("neutral", building[0], building[1], null)
	
	if neutral_pieces != [[]]:
		for piece in neutral_pieces:
			place_piece("", piece.unit_name, piece.unit_location, piece.ai_behaviour)
			
	
	
func place_piece(colour, unit, unit_position, ai_movement_behaviour):
	instantiate_unit(colour, unit, unit_position, ai_movement_behaviour)

func place_building(color, building_name, building_position, building_behaviour):
	instantiate_building(color, building_name, building_position, building_behaviour)
	
func instantiate_unit(colour, name, position, movement_id):
	var instance           = unit.instantiate()
	instance.unit_color    = colour
	instance.unit_name     = name
	instance.unit_position = position
	instance.movement_behaviour_id = movement_id
	instance.update_minimap.connect(update_minimap_squares)
	instance.determine_viable_squares.connect(determine_viable_squares_signal)
	instance.player_unit_lost.connect(player_unit_lost_signal)
	instance.summon_unit.connect(place_piece)

	#instance.place_unit()
	var square_parent = get_square(position[0], position[1])
	square_parent.add_child(instance)
	if instance.unit_color == "red":
		instance.moved = true
		instance.attacked = true
		computer_units.append(instance)
	elif instance.unit_color == "blue":
		player_units.append(instance)
	#units.add_child(instance)

func update_minimap_squares():
	emit_signal("update_minimap")


func determine_viable_squares_signal(type_viable, entity, bounds):
	var viable_squares = []
	var new_bounds = []
	
	for coord in bounds:
		if coord[0] > 0 and coord[1] > 0 and coord[0] < width and coord[1] < height:
			new_bounds.append(coord)
			
	if "empty" in type_viable:
		if  len(get_free_squares(new_bounds)) > 0:
			for square in get_free_squares(new_bounds):
				viable_squares.append(square)
	
	entity.viable_squares = viable_squares

func player_unit_lost_signal():
	emit_signal("player_unit_lost")

func instantiate_building(color, building_name, building_position, building_behaviour):
	var instance = building.instantiate()
	instance.building_color = color
	instance.building_stats = load("res://Resources/Buildings/"+building_name+".tres")
	instance.building_name = building_name
	instance.building_position = building_position
	#instance.building_behaviour = building_behaviour
	
	var square_parent = get_square(building_position[0], building_position[1])
	square_parent.add_child(instance)
	if instance.building_color == "red":
		computer_buildings.append(instance)
	else:
		player_buildings.append(instance)

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
	instance.square_selected.connect(square_selected_signal)
	instance.unit_selected  .connect(unit_selected_signal)
	instance.building_selected.connect(building_selected_signal)
	instance.unit_attack    .connect(unit_attack_signal)
	instance.unit_move      .connect(unit_move_signal)
	instance.unit_ability   .connect(unit_ability_signal)
	instance.show_movable   .connect(show_movable)
	instance.show_attackable.connect(show_attackable)
	squares.add_child(instance)

func square_selected_signal   (coords)           : emit_signal("square_selected"   , coords)
func unit_selected_signal     (coords,     unit) : emit_signal("unit_selected"     , coords, unit    )
func building_selected_signal (coords, building) : emit_signal("building_selected" , coords, building)

func unit_attack_signal       (coords)           : emit_signal("unit_attack"       , coords)
func unit_move_signal         (coords)           : emit_signal("unit_move"         , coords)
func unit_ability_signal      (coords)           : emit_signal("unit_ability"      , coords)

func show_abilitable (possible_moves):
	for move in possible_moves:
		get_square(move[0],move[1]).display_abililtable()

func show_movable(possible_moves):
	for move in possible_moves:
		get_square(move[0],move[1]).display_movable()

func show_attackable(possible_attacks):
	for attack in possible_attacks:
		get_square(attack[0], attack[1]).display_attackable()

func show_buildable(possible_builds):
	for build in possible_builds:
		get_square(build[0], build[1]).display_abilitable()

func get_square(x,y):
	for square_instance in squares.get_children():
		if square_instance.x_coord == x && square_instance.y_coord == y:
			return square_instance


func place_serialized_units(playerUnits, computerUnits):
	for unit in playerUnits:
		instantiate_unit_detailed("blue", unit.unit_name, unit.unit_position, unit.unit_movement_behaviour_id, unit.unit_health, unit.unit_max_health, unit.unit_moved, unit.unit_attacked)
		
	for unit in computerUnits:
		instantiate_unit_detailed("red", unit.unit_name, unit.unit_position, unit.unit_movement_behaviour_id, unit.unit_health, unit.unit_max_health, unit.unit_moved, unit.unit_attacked)
	

func get_free_squares(bounds):
	
	var free_squares = []
	for square in get_squares_from_array(bounds):
		if square.has_unit() == false && square.has_building() == false:
			free_squares.append([square.x_coord, square.y_coord])
	
	return free_squares
	
func get_free_square(bound_one, bound_two):
	var free_squares = []
	var possible_free_squares = get_squares(bound_one[0], bound_two[0], bound_one[1], bound_two[1])
	for square in possible_free_squares:
		if square.has_unit() == false && square.has_building() == false:
			free_squares.append(square)
	
	return free_squares

func get_squares(x_one, x_two, y_one, y_two):
	var squares = []

	for x in range (x_one, x_two+1):
		for y in range (y_one, y_two+1):
			if x > -1 && x < width && y >-1 && y < height:
				squares.append(get_square(x,y))
	
	return squares

func get_squares_from_array(array_of_coords):
	var squares = []
	for coord in array_of_coords:
		squares.append(get_square(coord[0], coord[1]))
	return squares
