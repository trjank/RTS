extends MouseCommands

@export var selection_box: Area2D
@export var selection_rect: CollisionShape2D

func _ready():
	set_command_icon(preload("res://mouse/commands/move_marker.png"))
	bind_cursor_to_action(preload("res://mouse/cursors/cursor_default.png"), NONE)
	bind_cursor_to_action(preload("res://mouse/cursors/cursor_select.png"), SELECT)
	bind_cursor_to_action(preload("res://mouse/cursors/cursor_move.png"), MOVE)
	bind_cursor_to_action(preload("res://mouse/cursors/cursor_target.png"), TARGET)

func _finish_selection()->void:
	clear_units()
	var selected := selection_box.get_overlapping_bodies()
	for unit in selected: if unit is Unit: select_unit(unit)

func _reset_selection_box(start: Vector2)->void:
	selection_box.position = start
	selection_rect.resize(Vector2.ZERO)

func _update_selection_box(start: Vector2, end: Vector2)->void:
	selection_box.position = 0.5 * (start + end)
	selection_rect.resize((end - start).abs())
