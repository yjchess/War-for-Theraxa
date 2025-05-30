extends Node2D
class_name Dialogue
signal submit_ui_update (StringName, Variant)

var current_dialogue = 0
var current_dialogue_set = 0
var in_dialogue = true
var start_new_dialogue = false


enum keys{
	PORTRAIT,
	NAME,
	DESCRIPTION
}

@export var optional_dialogue: Array[Dictionary]
@export var campaign_dialogue = [
	[
		{keys.PORTRAIT: "res://assets/portraits/commander_jensen.png", keys.NAME: "Commander Jensen", keys.DESCRIPTION: "[b]General Zardinius, troops at our outermost outpost have discovered an enemy scouting group! We must destroy them before they contact General Eelzeroth lest they send for reinforcements to break through our defenses![/b]"},
		{keys.PORTRAIT: "res://assets/portraits/commander_jensen.png", keys.NAME: "Commander Jensen", keys.DESCRIPTION: "[b]TEST! Test test test[/b]"},
		{keys.PORTRAIT: "res://assets/portraits/commander_jensen.png", keys.NAME: "Commander Jensen", keys.DESCRIPTION: "[b]TEST2! sad asd dsa[/b]"},		
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
		#print(current_dialogue)
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
		emit_signal("update_cutscene_dialogue", dialogue[keys.PORTRAIT], dialogue[keys.NAME], dialogue[keys.DESCRIPTION])
		
	elif start_new_dialogue == false:
		var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
		emit_signal("disable_mouse")
		emit_signal("update_cutscene_dialogue", dialogue[keys.PORTRAIT], dialogue[keys.NAME], dialogue[keys.DESCRIPTION])
		

func finished_from_middle():
	start_new_dialogue = false
	current_dialogue += 1

func finished_without_skipping():
	start_new_dialogue = false
	current_dialogue += 1
		
	#if current_dialogue < len(campaign_dialogue[current_dialogue_set]):
	#	await get_tree().create_timer(0.5).timeout
	#	var dialogue = campaign_dialogue[current_dialogue_set][current_dialogue]
	#	emit_signal("disable_mouse")
	#	emit_signal("update_cutscene_dialogue", dialogue.portrait, dialogue.name, dialogue.description)	

func _enter_tree() -> void:
	emit_signal("submit_ui_update", "dialogue", self)

func play_optional_dialogue(optional_dialogue_name):
	var optional_dialogue_set = null
	for dialogue_set in optional_dialogue:
		print(dialogue_set)
		if dialogue_set["dialogue_name"] == optional_dialogue_name:
			optional_dialogue_set = dialogue_set["dialogue_set"]
	
	if optional_dialogue_set == null:
		print("ERROR: Invalid dialogue_name")
		return
	
	else:
		campaign_dialogue.insert(current_dialogue_set, optional_dialogue_set)
		new_dialogue()
