extends Node2D


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

signal enable_mouse
signal disable_mouse
signal update_cutscene_dialogue

func new_dialogue():

	if current_dialogue_set > (len(campaign_dialogue)-1):
		print("END OF CAMPAIGN DIALOGUE")
		emit_signal("enable_mouse")
		return
		
	if current_dialogue > len(campaign_dialogue[current_dialogue_set])-1:
		print(current_dialogue)
		current_dialogue_set += 1
		current_dialogue = 0
		emit_signal("enable_mouse")
		return
	
	#if a characters has finished speaking - move on to the next piece of dialogue if there is one
	if start_new_dialogue == true:
		current_dialogue += 1	
		start_new_dialogue = false
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		emit_signal("disable_mouse")
		emit_signal("update_cutscene_dialogue", dialogue.portrait, dialogue.name, dialogue.description)
		
	elif start_new_dialogue == false:
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		emit_signal("disable_mouse")
		emit_signal("update_cutscene_dialogue", dialogue.portrait, dialogue.name, dialogue.description)
		
	
func finished_from_middle():
	start_new_dialogue = false
	current_dialogue += 1

func finished_without_skipping():
	start_new_dialogue = false
	current_dialogue += 1
	#if a characters has finished speaking - move on to the next piece of dialogue if there is one
	if start_new_dialogue == true:
		current_dialogue += 1	
		start_new_dialogue = false
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		emit_signal("disable_mouse")
		emit_signal("update_cutscene_dialogue", dialogue.portrait, dialogue.name, dialogue.description)
		
	elif start_new_dialogue == false:
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		emit_signal("disable_mouse")
		emit_signal("update_cutscene_dialogue", dialogue.portrait, dialogue.name, dialogue.description)
		
