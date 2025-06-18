extends MouseCommands

func _ready():
	#Unit.set_warp_visual(preload("res://battle/WarpPathVisual.tscn"))
	set_command_icon(preload("res://icons/move_marker.png"))
	bind_cursor_to_action(preload("res://icons/cursor_default.png"), NONE)
	bind_cursor_to_action(preload("res://icons/cursor_move.png"), MOVE)
	bind_cursor_to_action(preload("res://icons/cursor_target.png"), TARGET)

func _on_mouse_selection_selection_ended(selected):
	select_units(selected)
