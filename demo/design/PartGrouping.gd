extends PartGrouping

func _on_mouse_selection_selection_ended(selected):
	if not is_dragging(): select_parts(selected)
