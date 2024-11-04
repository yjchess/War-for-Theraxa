extends Node2D
var x_coord: int
var y_coord: int
var selected = false
signal override_square_selected
# Called when the node enters the scene tree for the first time.
func _ready():
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
		if selected == true:
			if GameData.selected_square != null:
				emit_signal("override_square_selected")
			GameData.selected_square = [x_coord, y_coord]
			change_panel_stylebox(8, "goldenrod")

		else:
			GameData.selected_square = null
			change_panel_stylebox(2, "262626")
		
