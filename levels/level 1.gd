extends Node2D
@onready var map = $Generic_Map
@onready var ui = $CanvasLayer
@onready var mouseblocker = $CanvasLayer/MouseBlocker/Area2D

var player_troops =   [["warrior", [1,10]],["warrior", [2,10]], ["archer", [1,11]],["archer", [2,11]], ["warrior", [9,10]],["warrior", [10,10]], ["archer", [9,11]],["archer", [10,11]]]
var computer_troops = [["warrior", [1,1], 3], ["warrior", [2,1], 3], ["cavalry_warrior", [1,0], 1], ["warrior", [9,1],3], ["warrior", [10,1],3], ["cavalry_warrior", [10,0],2]]
var current_dialogue = 0
var current_dialogue_set = 0
var in_dialogue = true
var start_new_dialogue = false

var keys = ["portrait", "name", "description"]
var campaign_dialogue = [
	[
		{keys[0]: "res://assets/portraits/commander_jensen.png", keys[1]: "Commander Jensen", keys[2]: "[b]General Zardinius, troops at our outermost outpost have discovered an enemy scouting group! We must destroy them before they contact General Eelzeroth lest they send for reinforcements to break through our defenses![/b]"},
		{keys[0]: "res://assets/portraits/commander_jensen.png", keys[1]: "Commander Jensen", keys[2]: "[b]TEST! Test test test[/b]"},
		{keys[0]: "res://assets/portraits/commander_jensen.png", keys[1]: "Commander Jensen", keys[2]: "[b]TEST2! sad asd dsa[/b]"},		
	]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	map.setup_board(player_troops, computer_troops)
	GameData.ui = ui
	GameData.update_minimap()
	GameData.connect_button()
	GameData.map = map
	
	#dialogue_finished means that the player let the dialogue run from start to finish
	ui.dialogue_finished.connect(finished_without_skipping)
	#mid_dialogue means the player clicked whilst there was still dialogue running
	mouseblocker.mid_dialogue.connect(finished_from_middle)
	#end_dialogue means the player clicked once mid dialogue then again
	mouseblocker.end_dialogue.connect(new_dialogue)
	
	new_dialogue()
	#var dialogue = campaign_dialogue[0][0]
	#ui.enable_mouseblocker()	
	#ui.update_cutscene_dialogue(dialogue.portrait, dialogue.name, dialogue.description)
	
func finished_from_middle():
	start_new_dialogue = false
	current_dialogue += 1

func finished_without_skipping():
	start_new_dialogue = false
	current_dialogue += 1
		
func new_dialogue():	
	if current_dialogue_set > (len(campaign_dialogue)-1):
		print("END OF CAMPAIGN DIALOGUE")
		ui.disable_mouseblocker()
		return
		
	if current_dialogue > len(campaign_dialogue[current_dialogue_set])-1:
		current_dialogue_set += 1
		current_dialogue = 0
		ui.disable_mouseblocker()
		return
		
	

	#if a characters has finished speaking - move on to the next piece of dialogue if there is one
	if start_new_dialogue == true:
		current_dialogue += 1	
		start_new_dialogue = false
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		ui.enable_mouseblocker()
		ui.update_cutscene_dialogue(dialogue.portrait, dialogue.name, dialogue.description)
		
	elif start_new_dialogue == false:
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		ui.enable_mouseblocker()
		ui.update_cutscene_dialogue(dialogue.portrait, dialogue.name, dialogue.description)
		
