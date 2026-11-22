extends PanelContainer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = not visible
