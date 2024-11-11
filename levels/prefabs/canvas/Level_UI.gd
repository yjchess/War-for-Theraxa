extends CanvasLayer
@onready var minimap = $Control/HBoxContainer/Minimap/Minimap/GridContainer
var minimap_square = preload("res://levels/prefabs/canvas/minimap_square.tscn")
signal end_turn

func _ready():
	minimap.columns = GameData.map_width
	populate_minimap_grid()
	
			
func populate_minimap_grid():
	for x in GameData.map_width:
		for y in GameData.map_height:
			var mini_square_instance = minimap_square.instantiate()
			minimap.add_child(mini_square_instance)
	
	#update_minimap_grid(GameData.squares)

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

func update_portrait(portrait):
	var texture = load(portrait)
	$%Portrait.texture = texture

func update_description(name, description):
	$%Name.text = name
	$%Description.text = "[b][fill]"+description+"[/fill][/b]"

func update_statistics(health, max_health, melee_damage, ranged_damage, attack_range, movement_range):
	$%health.text = str(health) + "/" + str(max_health)
	$%melee_damage.text = str(melee_damage)
	$%ranged_damage.text = str(ranged_damage)
	$%attack_range.text = str(attack_range)
	$%movement_range.text = str(movement_range)
	
	pass


func _on_end_turn_button_pressed():
	emit_signal("end_turn")
	pass # Replace with function body.
