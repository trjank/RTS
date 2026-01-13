extends UnitFormation

enum Action {NONE, MOVE, TARGET}

const CURSOR_CENTER_PX := Vector2i(16, 16)
const MOVE_MARKER_SIZE := Vector2i(64, 64)

const ICON_MOVE_MARKER    := preload("res://icons/move_marker.png")
const ICON_CURSOR_DEFAULT := preload("res://icons/cursor_default.png")
const ICON_CURSOR_MOVE    := preload("res://icons/cursor_move.png")
const ICON_CURSOR_TARGET  := preload("res://icons/cursor_target.png")

var queue_move := true
var action := Action.NONE

func _process(_dt: float)->void:
	if not is_curve_active(): return

	move_curve_to( get_global_mouse_position() )
	for n in range(count_targets()):
		get_child(n).global_position = get_target(n).get_position()

func _unhandled_input(event: InputEvent)->void:
	if event is InputEventMouseMotion: return

	if event.is_action_pressed("line formation"):
		formation = Formation.LINE
	elif event.is_action_pressed("v formation"):
		formation = V
	elif event.is_action_pressed("smooth formation"):
		formation = SMOOTH
	elif event.is_action_pressed("precise formation"):
		formation = PRECISE
	 
	if event.is_action_pressed("lock units"):
		order_units_to_toggle_lock(0.5)
	if event.is_action_pressed("toggle queue move"):
		queue_move = not queue_move
	if event.is_action_released("stop"):
		order_units_to_stop()

	if action == Action.NONE and event.is_action_pressed("select alt"):
		select_closest_unit_to( get_global_mouse_position(), 500)
	elif action == Action.MOVE and event.is_action_released("move"):
		if not queue_move: order_units_to_stop()
		end_curve(false)
		order_units_to_move()
		action = Action.NONE
		Input.set_custom_mouse_cursor(ICON_CURSOR_DEFAULT, Input.CURSOR_ARROW, CURSOR_CENTER_PX)
	elif action == Action.NONE and event.is_action_pressed("move"):
		action = Action.MOVE
		Input.set_custom_mouse_cursor(ICON_CURSOR_MOVE, Input.CURSOR_ARROW, CURSOR_CENTER_PX)
		begin_curve_at( get_global_mouse_position() );
	elif action == Action.TARGET and event.is_action_released("target"):
		end_curve(true)
		order_units_to_target()
		action = Action.NONE
		Input.set_custom_mouse_cursor(ICON_CURSOR_DEFAULT, Input.CURSOR_ARROW, CURSOR_CENTER_PX)
	elif action == Action.NONE and event.is_action_pressed("target"):
		action = Action.TARGET
		Input.set_custom_mouse_cursor(ICON_CURSOR_TARGET, Input.CURSOR_ARROW, CURSOR_CENTER_PX)
		begin_curve_at( get_global_mouse_position() )

func _on_mouse_selection_selection_ended(selected: Array[Node2D], _region: Rect2):
	set_units_selected(false)
	select_units(selected)
	set_units_selected(true)

func _on_path_started():
	for n in range(count_targets()):
		var move_marker := ResizableSprite2D.new()
		move_marker.texture = ICON_MOVE_MARKER
		move_marker.resize(MOVE_MARKER_SIZE)
		add_child(move_marker)

func _on_path_ended():
	for move_marker in get_children():
		move_marker.queue_free()
