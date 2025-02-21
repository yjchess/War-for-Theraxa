extends Control

@onready var disabled = $Container
#@export var tooltip_content = "Achievement for beating the level"
@export var achieved = false
@export var special: bool = false
@export var super_special:bool = false
@export var already_achieved = false

func _ready():	
	#tooltip_text = tooltip_content
	
	if special:
		$Special.visible = true
	elif super_special:
		$Super_Special.visible = true
	
	if achieved:
		enable()
	
	if already_achieved:
		print("Already Achieved")
		disabled.hide()

func enable():
	for i in range(50):
		await get_tree().create_timer(0.0125).timeout
		disabled.size.x -= 1
		disabled.position.x +=1
