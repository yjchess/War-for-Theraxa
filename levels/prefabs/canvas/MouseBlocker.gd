extends Area2D
signal mid_dialogue
signal end_dialogue
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if $%Description.visible_ratio != 1:
			$%Description.visible_ratio = 1
			print("mid dialogue signal sent")
			emit_signal("mid_dialogue")
		else:
			print("end dialogue signal sent")
			emit_signal("end_dialogue")
