extends TextureButton

@onready var normal_state = $Normal
@onready var pressed_state = $Pressed
@onready var hovered_state = $Hovered
@onready var states = [normal_state, pressed_state, hovered_state]

@export var ability_name = "movement"
@export var ability_description = "The squares a unit can move to."
signal abililty_pressed

var button_pressed_bool = false

func _ready():
	var texture = load("res://assets/icons/"+ability_name+".png")
	set_texture_normal(texture)
	tooltip_text = ability_description

func _on_pressed():
	hide_states()
	button_pressed_bool = !button_pressed_bool
	if button_pressed_bool == true:
		$Pressed.visible = true
		GameData.ability_pressed(ability_name)
	else:
		$Normal.visible = true		

func _on_mouse_entered():
	if !button_pressed_bool:
		hide_states()
		$Hovered.visible = true


#func _gui_input(event):
#	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
#		hide_states()
#		$Pressed.visible = true


func hide_states():
	for state in states:
		state.visible = false





func _on_mouse_exited():
	if !button_pressed_bool:
		hide_states()
		$Normal.visible = true
