extends MouseCommands

enum Action { NONE, SELECT, MOVE, FOLLOW, TARGET }

const CURSOR_DEFAULT := preload("res://mouse/cursors/cursor_default.png")
const CURSOR_SELECT  := preload("res://mouse/cursors/cursor_select.png")
const CURSOR_MOVE    := preload("res://mouse/cursors/cursor_move.png")
const CURSOR_FOLLOW  := preload("res://mouse/cursors/cursor_follow.png")
const CURSOR_TARGET  := preload("res://mouse/cursors/cursor_target.png")
const CURSOR_CENTER  := Vector2i(16, 16)

@export var selection_box: Area2D
@export var selection_rect: CollisionShape2D
var selection_start: Vector2
var selection_end: Vector2
var __action := Action.NONE

func set_action(new_action: Action, cursor := CURSOR_DEFAULT)->void:
	__action = new_action
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, CURSOR_CENTER)

func reset_selection()->void:
	selection_start = get_global_mouse_position()
	selection_box.position = selection_start
	selection_rect.resize(Vector2.ZERO)

func update_selection()->void:
	selection_end = get_global_mouse_position()
	selection_box.position = 0.5 * (selection_start + selection_end)
	selection_rect.resize((selection_end - selection_start).abs())

func _process(_dt):
	match __action:
		Action.SELECT: update_selection()
		Action.TARGET: update_target()
		Action.MOVE, Action.FOLLOW: update_path()

func _unhandled_input(event):
	if event is InputEventMouseMotion: return
	match __action:
		# Unit selection --------------------------------------------
		Action.NONE when Input.is_action_just_pressed("left_click"):
			set_action(Action.SELECT, CURSOR_SELECT)
			reset_selection()
		Action.SELECT when Input.is_action_just_released("left_click"):
			print(selection_box.get_overlapping_bodies())
			set_action(Action.NONE)
			reset_selection()
		# Move command ----------------------------------------------
		Action.NONE when Input.is_action_just_pressed("move"):
			set_action(Action.MOVE, CURSOR_MOVE)
			begin_path()
		Action.MOVE when Input.is_action_just_released("move"):
			order_units_to_move()
			set_action(Action.NONE)
		# Follow command --------------------------------------------
		Action.NONE when Input.is_action_just_pressed("follow"):
			set_action(Action.FOLLOW, CURSOR_FOLLOW)
			begin_path()
		Action.FOLLOW when Input.is_action_just_released("follow"):
			order_units_to_move()
			set_action(Action.NONE)
		# Manual firing ---------------------------------------------
		Action.NONE when Input.is_action_just_released("target"):
			set_action(Action.TARGET, CURSOR_TARGET)
		Action.TARGET when Input.is_action_just_released("target"):
			set_action(Action.NONE)
