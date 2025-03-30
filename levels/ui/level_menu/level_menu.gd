extends Control
signal surrender
signal save_game
signal load_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_menu_pressed():
	hide()


func _on_surrender_pressed():
	hide()
	emit_signal("surrender")


func _on_save_game_pressed():
	emit_signal("save_game")
	GameData.save_game()


func _on_load_save_pressed():
	#print("ATTEMPTING TO LOAD GAME")
	GameData.load_game()
