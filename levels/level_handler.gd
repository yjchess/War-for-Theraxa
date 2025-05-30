extends Node2D
class_name LEVEL_HANDLER

var player_resources = {"food":0, "gold":0}:
	set(v):
		print("HELLO")
		player_resources = v
		submit_ui_update.emit("player_resources", player_resources)
		
var computer_resources = {"food":0, "gold":0}:
		set(v):
			computer_resources = v
			submit_ui_update.emit("computer_resources", computer_resources)


signal submit_ui_update (StringName, Variant)

func _enter_tree() -> void:
	emit_signal("submit_ui_update", "player_resources", player_resources)
	var cs = get_tree().current_scene
	_listen(cs)

func _listen(node: Node):

	if not node.has_signal("submit_level_update"):
		return
	else:
		print("Listening to: ",node.name," from: LEVEL_HANDLER")
	node.submit_level_update.connect(_submit_update)

func _submit_update(key: StringName, value: Variant):
	print(key, value)
	match key:
		"player_resources": 
			add_to_dict(player_resources, value)
			submit_ui_update.emit("player_resources", player_resources)
		"computer_resources":add_to_dict(computer_resources, value)
	
func add_to_dict(dict, new_dict:Dictionary):
	for key in new_dict.keys():
		dict[key] += new_dict[key]
	
	print("NEW DICT: ", dict)


func _on_level_child_entered_tree(node: Node) -> void:
	node.child_entered_tree.connect(_on_level_child_entered_tree)
	_listen(node)
