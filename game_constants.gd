extends Node

const farm = {"food_cost": 50, "gold_cost":0}


func get_constant(name):
	match name:
		"farm": return farm
