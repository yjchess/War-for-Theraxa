extends Resource
class_name Building_Stats

@export var building_types:Array[Building_Type] = [Building_Type.NORMAL]
@export var building_name:String                = "barracks"
@export var health:int                          = 15
@export var base_path:String                    = "res://assets/human/buildings/"
@export var description:String                  = "The training facility for melee soldiers."
@export var sprite_scale: Vector2               = Vector2(1,1)
@export var sprite_offset: Vector2              = Vector2(0,0)
@export var abilities: Array[String]            =  ["warrior"]

enum Building_Type {
		NORMAL,
		GATHERABLE,
		TRAINABLE
	}
