extends MouseSelection

func _on_part_grouping_dragging_started():
	enabled = false

func _on_part_grouping_dragging_ended():
	enabled = true
