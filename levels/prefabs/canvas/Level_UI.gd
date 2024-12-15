extends CanvasLayer
@onready var minimap = $%minimap
var minimap_square = preload("res://levels/prefabs/canvas/minimap_square.tscn")
var victory_screen = preload("res://levels/prefabs/victory_screen.tscn")
var defeat_screen = preload("res://levels/prefabs/defeat_screen.tscn")
signal end_turn
signal dialogue_finished
@onready var mouseblocker = $MouseBlocker/Area2D
var skipped = false

var ability_button = preload("res://levels/prefabs/canvas/ability_button.tscn")

func _ready():
	minimap.columns = GameData.map_width
	populate_minimap_grid()
	mouseblocker.mid_dialogue.connect(skip)

func skip():
	skipped = true
			
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
	minimap.get_child(index).get_node("None").visible = false
	#print(type)
	match type:
		"player"  :minimap.get_child(index).get_node("Player_Controlled").visible = true
		"computer":minimap.get_child(index).get_node("Computer_Controlled").visible = true
		"neutral" :minimap.get_child(index).get_node("Neutral").visible = true
		"none"    :minimap.get_child(index).get_node("None").visible = true

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
	
func update_cutscene_dialogue(portrait, name, dialogue):
	update_portrait(portrait)
	update_description(name, dialogue)
	
	var total_characters = $%Description.get_total_character_count()
	$%Description.visible_characters = 0	
	
	skipped = false
	for character in total_characters:
		await get_tree().create_timer(0.0625).timeout
		if skipped == true:
			break
		if $%Description.visible_ratio != 1:
			$%Description.visible_characters += 1
	
	if skipped == false:
		#print("dialogue_finished signal sent")
		emit_signal("dialogue_finished")
		
	#print($%Description.visible_ratio)
	#$MouseBlocker.visible = false
	

func _on_end_turn_button_pressed():
	emit_signal("end_turn")

func disable_mouseblocker():
	$MouseBlocker.visible = false

func enable_mouseblocker():
	$MouseBlocker.visible = true

func show_winner(winner, achievements, special_achievements, super_special_achievements):
	if winner == "player":
		var instance = victory_screen.instantiate()
		instance.populate_achievements(achievements)
		instance.populate_special_achievements(special_achievements)
		instance.populate_super_special_achievements(super_special_achievements)
		instance.show_previously_achieved(GameData.previously_achieved)
		add_child(instance)
		
	elif winner == "computer":
		var instance = defeat_screen.instantiate()
		instance.populate_achievements(achievements)
		instance.populate_special_achievements(special_achievements)
		instance.populate_super_special_achievements(super_special_achievements)
		instance.show_previously_achieved(GameData.previously_achieved)
		add_child(instance)


func _on_open_menu_pressed():
	$Level_Menu.visible = true

func update_abilities(abilities):
	if len(abilities) > 0:
		var image
		
		for ability_shown in %abilities_container.get_children():
			ability_shown.queue_free()
		
		for ability in abilities:
			var instance = ability_button.instantiate()
			instance.ability_name = ability
			%abilities_container.add_child(instance)
	else:
		if %abilities_container.get_child_count() > 0:
			for ability_shown in %abilities_container.get_children():
				ability_shown.queue_free()
