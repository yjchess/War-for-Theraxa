extends Node2D
var x_coord: int
var y_coord: int

var x_max: int
var y_max: int
var selected = false

signal square_selected
signal unit_selected
signal building_selected

signal unit_attack
signal unit_move
signal unit_ability

signal show_attackable
signal show_movable
signal show_abilitable
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("squares")


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
	#GameData.selected_square = null

func _on_area_2d_input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected = !selected
		
		if $Attackable.visible == true: emit_signal("unit_attack", [x_coord, y_coord])
		
		if $Movable.   visible == true: emit_signal("unit_move", [x_coord, y_coord])
		
		if $Abilitable.visible == true: emit_signal("unit_ability", [x_coord, y_coord])
		
		get_tree().call_group("movable_square_UI"   , "hide")
		get_tree().call_group("attackable_square_UI", "hide")
		get_tree().call_group("abilitable_square_UI", "hide")
		
		if selected == true:
			change_panel_stylebox(8, "goldenrod")
			if get_node_or_null("Unit") != null && $Attackable.visible != true:
				#propagated: square --> generic_map --> level
				emit_signal("unit_selected", [x_coord, y_coord], $Unit)

			
			elif get_node_or_null("Building") != null && $Attackable.visible != true:
				emit_signal("building_selected", [x_coord, y_coord], $Building)			

			emit_signal("square_selected", [x_coord, y_coord])
				
			
			if self.get_node_or_null("Unit")!= null:
				var unit = self.get_node_or_null("Unit")
				if unit.unit_color =="blue":
					emit_signal("show_movable",    unit.get_unit_possible_moves  ())
					emit_signal("show_attackable", unit.get_unit_possible_attacks())

		
		else:
			deselect()
			emit_signal("square_selected", null)


func display_movable   (): get_node("Movable"   ).visible = true
func display_attackable(): get_node("Attackable").visible = true
func display_abilitable(): get_node("Abilitable").visible = true
	
func remove_unit(): get_node("Unit").queue_free()

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
