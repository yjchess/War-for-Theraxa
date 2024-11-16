extends Control

@onready var disabled = $Container
#@export var tooltip_content = "Achievement for beating the level"
@export var achieved = false
@export var special: bool = false

func _ready():
	
	#tooltip_text = tooltip_content
	
	if special:
		$Special.visible = true
		$Enabled.visible = false
	
	if achieved:
		enable()


func enable():
	for i in range(50):
		await get_tree().create_timer(0.0125).timeout
		disabled.size.x -= 1
		disabled.position.x +=1
