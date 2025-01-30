extends TextureButton

@onready var normal_state = $Normal
@onready var pressed_state = $Pressed
@onready var hovered_state = $Hovered
@onready var states = [pressed_state, hovered_state]

@export var ability_name = "movement"
@export var ability_description = "The squares a unit can move to."
signal ability_pressed
signal ability_unpressed

var button_pressed_bool = false

func _ready():
	#parent is level_ui.gd
	add_to_group("ability_buttons")
	var texture = load("res://assets/icons/"+ability_name+".png")
	set_texture_normal(texture)
	tooltip_text = ability_description

func _on_pressed():
	get_tree().call_group("ability_buttons", "off", self)
	button_pressed_bool = !button_pressed_bool
	if button_pressed_bool == true:
		$Pressed.visible = true
		emit_signal("ability_pressed", ability_name)		

func _on_mouse_entered():
	if !button_pressed_bool:
		hide_states()
		$Hovered.visible = true


func hide_states():
	for state in states:
		state.visible = false

func _on_mouse_exited():
	if !button_pressed_bool:
		hide_states()

func off(origin_button):
	emit_signal("ability_unpressed")
	if self == origin_button:
		hide_states()
		return
	button_pressed_bool = false
	hide_states()
