extends PartGrouping

signal dragging_started
signal dragging_ended

const ROTATION_DURATION_SEC := 0.15

@export var mirror_axis: Line2D
@export var mirror_button: TextureButton

var dragging := false
var mouse_offset := Vector2.ZERO
var mirror: PartGrouping = null

func begin_dragging()->void:
	mouse_offset = get_global_mouse_position() - get_global_position();
	dragging = true
	dragging_started.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);

func stop_dragging()->void:
	snap_to_grid()
	dragging = false
	dragging_ended.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func reposition_mirrored()->void:
	if not mirror: return
	# Flip the position across the mirror axis (horizontally)
	var x_offset := position.x - mirror_axis.position.x
	mirror.position.x = mirror_axis.position.x - x_offset
	mirror.position.y = position.y

func _on_mouse_selection_selection_ended(selected: Array[Node2D], rect: Rect2)->void:
	select_parts(selected, rect)

func _on_parts_rotated(quarter_turns: int, duration: float)->void:
	if mirror: mirror.rotate_parts( -quarter_turns, duration)

func _on_dragging_started()->void:
	if not mirror_button.mirror_mode: return
	# Create a mirrored version
	mirror = duplicate()
	get_parent().add_child(mirror)
	mirror.flip_parts()
	parts_flipped.connect(mirror.flip_parts)
	parts_deleted.connect(mirror.delete_parts)
	mirror.parts_deleted.connect(mirror.queue_free)

func _on_dragging_ended()->void:
	if not mirror: return
	# Cleanup the mirrored version
	mirror.snap_to_grid()
	mirror.clear_parts()
	mirror.queue_free()
	mirror = null

func _input(event: InputEvent)->void:
	if event.is_action_released("delete"):
		delete_parts()
	if event.is_action_pressed("select") and contains_mouse() and get_child_count() > 0:
		begin_dragging()
	if dragging:
		handle_drag_input(event)

func handle_drag_input(event: InputEvent)->void:
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - mouse_offset
		reposition_mirrored()
	if event.is_action_pressed("flip"):
		flip_parts()
	if event.is_action_pressed("rotate cw"):
		rotate_parts(CLOCKWISE, ROTATION_DURATION_SEC)
	if event.is_action_pressed("rotate ccw"):
		rotate_parts(COUNTER_CLOCKWISE, ROTATION_DURATION_SEC)
	if event.is_action_released("select"):
		stop_dragging()
