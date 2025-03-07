extends MouseCommands

@export var selection: MouseSelection

func _ready():
	Unit.set_warp_visual(preload("res://battle/WarpPathVisual.tscn"))
	set_command_icon(preload("res://mouse/commands/move_marker.png"))
	bind_cursor_to_action(preload("res://mouse/cursors/test.png"), NONE)
	bind_cursor_to_action(preload("res://mouse/cursors/move.png"), MOVE)
	bind_cursor_to_action(preload("res://mouse/cursors/target.png"), TARGET)
	selection.selection_ended.connect(select_units)
