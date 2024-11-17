extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_level_change(level):
	var level_path = "res://levels/"+level+".tscn"
	get_tree().change_scene_to_file(level_path)
	pass # Replace with function body.


func _on_castle_button_pressed():
	get_tree().change_scene_to_file("res://levels/castle.tcsn")
	pass # Replace with function body.
