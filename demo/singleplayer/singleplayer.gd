class_name Singleplayer extends Battle

@export var tech_tree: TechTree

func _on_tech_tree_button_pressed() -> void:
	tech_tree.visible = true
