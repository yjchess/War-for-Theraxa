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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
		if $Movable.visible == true:
			GameData.selected_unit.move(x_coord, y_coord)
			
		if selected == true:
			if get_node_or_null("Unit") != null && $Attackable.visible != true:
				GameData.selected_unit = $Unit
			
			if GameData.selected_square != null:
				emit_signal("override_square_selected")
			
			GameData.selected_square = [x_coord, y_coord]
			change_panel_stylebox(8, "goldenrod")
			
			if self.get_node_or_null("Unit")!= null:
				var unit = self.get_node_or_null("Unit")
				for move in unit.get_unit_possible_moves():
					if move[0] < x_max && move[0] > -1 && move[1] < y_max && move[1] > -1:
						if !(move[0] == x_coord && move[1] == y_coord):
							map.get_square(move[0],move[1]).display_movable()

		else:
			emit_signal("override_square_selected")
			GameData.selected_square = null
			change_panel_stylebox(2, "262626")

func display_movable():
	get_node("Movable").visible = true

func display_attackable():
	get_node("Attackable").visible = true
	
func remove_unit():
	get_node("Unit").queue_free()
