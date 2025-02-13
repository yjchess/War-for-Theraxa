class_name Unit_Spawn extends Resource

@export var unit_name: String 
@export var unit_location: Array
@export var ai_behaviour: int

func _init(new_name, new_location, new_ai):
	unit_name = new_name
	unit_location = new_location
	ai_behaviour = new_ai

	
