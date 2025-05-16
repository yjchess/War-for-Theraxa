class_name Ability_Stats extends Resource

@export var ability_name       :String = "summon_skeleton"
@export var cooldown              :int = 1
@export var ability_range         :int = 2
@export var ability_aoe           :int = 0
@export var types_viable:Array[String] = ["empty"]

@export var ability_vars :Dictionary   = {}
@export var ability_types:Array[ability_type] =[ability_type.SUMMON]

enum ability_type{
	HEALTH_EFFECT,
	STATUS_EFFECT,
	SUMMON,
	TRAIN,
	GATHER
}
