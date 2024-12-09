extends Node2D
var x_coord: int
var y_coord: int

var x_max: int
var y_max: int
var selected = false
var map

signal override_square_selected
# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_parent().get_parent()


func change_panel_stylebox(border_length, color):
	var stylebox = $Panel.get_theme_stylebox("panel")
	stylebox.border_width_left = border_length
	stylebox.border_width_right = border_length
	stylebox.border_width_top = border_length
	stylebox.border_width_bottom = border_length
	stylebox.border_color = color
		
func _on_area_2d_mouse_entered():
	if !selected:
		change_panel_stylebox(8, "teal")
		

func _on_area_2d_mouse_exited():
	if !selected:
		change_panel_stylebox(2, "262626")
	
#the following function will be used in the game script
func deselect():
	change_panel_stylebox(2, "262626")
	selected = false
	GameData.selected_square = null

func _on_area_2d_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected = !selected
		
		if $Attackable.visible == true:
			GameData.selected_unit.attack(x_coord, y_coord)
		
		if $Movable.visible == true:
			GameData.selected_unit.move(x_coord, y_coord)
		
		if $Abilitable.visible == true:
			GameData.selected_ability.use_ability(GameData.selected_ability.ability_name)
			
		if selected == true:
			if get_node_or_null("Unit") != null && $Attackable.visible != true:
				GameData.selected_building = null
				GameData.selected_unit = $Unit
				GameData.update_unit_ui()
			
			elif get_node_or_null("Building") != null && $Attackable.visible != true:
				GameData.selected_unit = null
				GameData.selected_building = $Building
				GameData.update_building_ui()
				
			if GameData.selected_square != null:
				emit_signal("override_square_selected")
			
			GameData.selected_square = [x_coord, y_coord]
			change_panel_stylebox(8, "goldenrod")
			
			if self.get_node_or_null("Unit")!= null:
				var unit = self.get_node_or_null("Unit")
				if unit.unit_color =="blue":
					for move in unit.get_unit_possible_moves():
						map.get_square(move[0],move[1]).display_movable()
					
					for attack in unit.get_unit_possible_attacks():
						map.get_square(attack[0], attack[1]).display_attackable()

		else:
			emit_signal("override_square_selected")
			GameData.selected_square = null
			change_panel_stylebox(2, "262626")

func display_movable():
	get_node("Movable").visible = true

func display_attackable():
	get_node("Attackable").visible = true

func display_abilitable():
	get_node("Abilitable").visible = true
	
func remove_unit():
	get_node("Unit").queue_free()

func has_unit():
	if get_node_or_null("Unit") != null: return true
	else: return false

func has_enemy_unit(color):
	if get_node_or_null("Unit") != null:
		if (color == "red" && get_node("Unit").unit_color =="blue") || (color=="blue" && get_node("Unit").unit_color=="red"):
			return true
	else: return false


func has_building():
	if get_node_or_null("Building") != null: return true
	else: return false

func has_enemy_building(color):
	if get_node_or_null("Building") != null:
		if (color == "red" && get_node("Building").building_color =="blue") || (color=="blue" && get_node("Building").building_color=="red"):
			return true
	else: return false

func get_player():
	var player
	if get_node_or_null("Unit") != null:
		player = get_node_or_null("Unit").player
	elif get_node_or_null("Building") != null:
		player = get_node_or_null("Building").player
	else: player = "none"
	return player
