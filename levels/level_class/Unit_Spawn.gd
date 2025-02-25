class_name Unit_Spawn extends Resource

@export var unit_name: String 
@export var unit_location: Array
@export var ai_behaviour: int
@export var ai_vars:Dictionary

func _init(new_name, new_location, new_ai_vars ):
	unit_name = new_name
	unit_location = new_location

	match new_ai_vars[0]:
		"fastest": ai_vars = {"ai_type": "fastest_route", "destination": new_ai_vars[1]}
		"pre_determined": ai_vars = {"ai_type": "pre_determined", "pre_determined_moves": new_ai_vars[1], "pacifist": new_ai_vars[2] }
		_: ai_vars = {"ai_type":"generic"}
	
