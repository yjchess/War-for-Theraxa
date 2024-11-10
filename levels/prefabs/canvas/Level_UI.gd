extends CanvasLayer
@onready var minimap = $Control/HBoxContainer/Minimap/Minimap/GridContainer
var minimap_square = preload("res://levels/prefabs/canvas/minimap_square.tscn")

func _ready():
	minimap.columns = GameData.map_width
	await  get_tree().create_timer(1).timeout
	populate_minimap_grid()
	
			
func populate_minimap_grid():
	for x in GameData.map_width:
		for y in GameData.map_height:
			var mini_square_instance = minimap_square.instantiate()
			minimap.add_child(mini_square_instance)
	
	update_minimap_grid(GameData.squares)

func update_minimap_grid(squares):
	var minimap = GameData.calculate_minimap(squares)
	
	var i = -1
	for square in minimap:
		i+=1
		change_minimap_square(square, i)

		
func change_minimap_square(type, index):
	
	minimap.get_child(index).get_node("Player_Controlled").visible = false
	minimap.get_child(index).get_node("Computer_Controlled").visible = false
	minimap.get_child(index).get_node("Neutral").visible = false	
	#print(type)
	match type:
		"player"  :minimap.get_child(index).get_node("Player_Controlled").visible = true
		"computer":	minimap.get_child(index).get_node("Computer_Controlled").visible = true
		"neutral" :minimap.get_child(index).get_node("Neutral").visible = true	
