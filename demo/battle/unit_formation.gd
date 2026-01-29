class_name UnitFormation extends Path2D

signal formation_changed(new_formation: Formation)
signal action_changed(new_action: Action)

enum Action {
	NONE,
	MOVE,
	QUEUE_MOVE,
	TARGET,
	SNAP_TARGET
}
enum Formation {
	LINE = 2,
	V = 3,
	SMOOTH = 10,
	PRECISE = 30
}

const MOUSE_CURSORS: Dictionary[Action, Texture2D] = {
	Action.NONE: preload("res://icons/cursor_default.png"),
	Action.MOVE: preload("res://icons/cursor_move.png"),
	Action.QUEUE_MOVE: preload("res://icons/cursor_move.png"),
	Action.TARGET: preload("res://icons/cursor_target.png"),
	Action.SNAP_TARGET: preload("res://icons/cursor_target.png")
}
const ICONS: Dictionary[Action, Texture2D] = {
	Action.NONE: null,
	Action.MOVE: preload("res://icons/formation_move.png"),
	Action.QUEUE_MOVE: preload("res://icons/formation_move.png"),
	Action.TARGET: preload("res://icons/formation_target.png"),
	Action.SNAP_TARGET: preload("res://icons/formation_target.png")
}
const MOUSE_CURSOR_CENTER := Vector2(16.0, 16.0)
const MAX_SELECTION_DISTANCE := 100.0
const MAX_CLEANUP_ITERATIONS := 10
# NOTE: These are used in move_curve()
const UNSTABLE_CURVE_LENGTH := 0.1
const NO_DIVIDE_ZERO := 0.001

@export var draw_curve := false
@export var curve_draw_width := 2.0
@export var curve_draw_color := Color.WHITE
@export var mouse_selection: MouseSelection

var action := Action.NONE:
	set = set_action
var formation := Formation.LINE:
	set = set_formation

var _targets: Array[Target] = []
var _units: Array[RadarSignature] = []
var _sort_axis := Vector2.RIGHT
var _center_targets := Vector2.ZERO
var _center_units := Vector2.ZERO

func _ready() -> void:
	set_process(false)

func is_dragging() -> bool:
	return is_processing()

func get_unit(i: int) -> RadarSignature:
	return _units[i]

func get_target(i: int) -> Target:
	return _targets[i]

func set_action(new_action: Action) -> void:
	action = new_action
	action_changed.emit(action)
	Input.set_custom_mouse_cursor(MOUSE_CURSORS[action], Input.CURSOR_ARROW, MOUSE_CURSOR_CENTER)

func set_formation(new_formation: Formation) -> void:
	# NOTE: This prevents bad integer casts from causing errors
	formation = maxi(new_formation, Formation.LINE) as Formation
	formation_changed.emit(formation)

func count_locked_units() -> int:
	return _units.filter(_is_unit_locked).size()

func _is_unit_locked(unit: RadarSignature) -> bool:
	return unit.is_alive() and unit.as_unit().movement_locked

func _command_unit(num_failed: int, i: int, f: Callable) -> int:
	var unit := _units[i]
	var target := _targets[i]
	return num_failed + int(f.call(unit, target) == false) if unit.is_alive() else num_failed

func command_units(f: Callable) -> int:
	assert(_units.size() == _targets.size() )
	#
	return range(_units.size() ).reduce(_command_unit.bind(f), 0)

func command_units_to_stop() -> void:
	return command_units(func (unit: RadarSignature, __: Target) -> void: unit.as_unit().clear_waypoints() )

func command_units_to_move() -> int:
	return command_units(func (unit: RadarSignature, target: Target) -> bool: return unit.as_unit().queue_waypoint(target) )

func command_units_to_target() -> int:
	return command_units(func (unit: RadarSignature, target: Target) -> bool: return unit.as_unit().set_target(target) )

func set_units_selected(selected: bool) -> void:
	command_units(func (unit: RadarSignature, __: Target) -> void: unit.as_unit().selected = selected)

func set_units_movement_lock(lock: bool) -> void:
	command_units(func (unit: RadarSignature, __: Target) -> void: unit.as_unit().movement_locked = lock)

func toggle_units_movement_lock(threshold := 0.5) -> void:
	assert(0.0 <= threshold and threshold <= 1.0)
	#
	set_units_movement_lock(count_locked_units() <= threshold * _units.size() )

func select_units(selection: Array) -> void:
	if null in selection:
		selection = []
	set_units_selected(false)
	_units.assign(selection)
	_targets.resize(_units.size() )
	set_units_selected(true)

func begin_dragging() -> void:
	if _units.is_empty():
		return
	mouse_selection.disable()
	begin_curve(get_global_mouse_position() )
	set_process(true)

func stop_dragging() -> void:
	set_process(false)
	end_curve()
	mouse_selection.enable()
	queue_redraw()

func begin_curve(start: Vector2) -> void:
	curve.clear_points()
	for i in int(formation):
		curve.add_point(start)
	for i in _targets.size():
		_targets[i] = Target.new(start)
	queue_redraw()

func move_curve(new_endpoint: Vector2) -> void:
	var length := curve.get_baked_length()
	curve.set_point_position(curve.point_count - 1, new_endpoint)
	if length <= UNSTABLE_CURVE_LENGTH:
		return
	var targets_step := length / (_targets.size() - 1 + NO_DIVIDE_ZERO)
	var segment_length := length / (curve.point_count - 1)
	for i in range(1, curve.point_count - 1):
		curve.set_point_position(i, curve.sample_baked(i * segment_length) )
	for i in _targets.size():
		_targets[i].position = curve.sample_baked(i * targets_step)
	queue_redraw()

func end_curve() -> void:
	_center_units = calculate_center(_units, _center_calculation_units)
	_center_targets = calculate_center(_targets, _center_calculation_targets)
	_sort_axis = _center_targets - _center_units
	_units.sort_custom(_axis_sorter_units)
	_targets.sort_custom(_axis_sorter_targets)
	cleanup_path_intersections()

func calculate_center(objects: Array, calculation: Callable) -> Vector2:
	return objects.reduce(calculation, Vector2.ZERO) / objects.size()

func _center_calculation_targets(sum: Vector2, unit: Target) -> Vector2:
	return sum + unit.position

func _center_calculation_units(sum: Vector2, unit: RadarSignature) -> Vector2:
	return sum + unit.get_future_position()

func cleanup_path_intersections() -> int:
	var iterations := 0
	while iterations < MAX_CLEANUP_ITERATIONS and _try_to_swap():
		iterations += 1
	return iterations

func _try_to_swap() -> bool:
	var swapped := false
	for i in _targets.size() - 1:
		swapped = swapped or _swap_path_endpoints(i, i + 1)
	return swapped

func _swap_path_endpoints(i: int, j: int) -> bool:
	if not _do_paths_intersect(i, j):
		return false
	var temp := _targets[i]
	_targets[i] = _targets[j]
	_targets[j] = temp
	return true

func _do_paths_intersect(i: int, j: int) -> bool:
	return Geometry2D.segment_intersects_segment(
		_units[i].get_future_position(),
		_targets[i].position,
		_units[j].get_future_position(),
		_targets[j].position
	) != null

func get_nearest_unit(to: Vector2) -> RadarSignature:
	var sorter := MouseSelection.distance_sorter.bind(to)
	var units := mouse_selection.sorted_query(to, sorter, MAX_SELECTION_DISTANCE)
	return null if units.is_empty() else units[0].get_radar_signature()

func snap_targets() -> void:
	for i in _targets.size():
		_targets[i] = get_nearest_unit(_targets[i].position)
	queue_redraw()

func _snap_target_to_nearest_unit(i: int) -> void:
	_targets[i] = get_nearest_unit(_targets[i].position)

func _draw_target(target: Target) -> void:
	if target == null:
		return
	var icon := ICONS[action]
	draw_texture(icon, target.position - icon.get_size() / 2)

func _draw() -> void:
	if not is_dragging():
		return
	draw_set_transform_matrix(global_transform.affine_inverse() )
	if draw_curve:
		draw_polyline(curve.get_baked_points(), curve_draw_color, curve_draw_width)
	for target in _targets:
		_draw_target(target)

func _axis_sorter_units(a: RadarSignature, b: RadarSignature) -> bool:
	var a_offset := a.get_future_position() - _center_units
	var b_offset := b.get_future_position() - _center_units
	return a_offset.cross(_sort_axis) < b_offset.cross(_sort_axis)

func _axis_sorter_targets(a: Target, b: Target) -> bool:
	var a_offset := a.position - _center_targets
	var b_offset := b.position - _center_targets
	return a_offset.cross(_sort_axis) < b_offset.cross(_sort_axis)

func _on_mouse_selection_selected(bodies: Array[Node2D], _rect: Rect2) -> void:
	select_units(bodies.map(Unit.to_radar_signature) )

func _process(_dt: float) -> void:
	move_curve(get_global_mouse_position() )

func _handle_target_input(event: InputEvent) -> void:
	if action == Action.NONE and event.is_action_pressed("target"):
		begin_dragging()
		action = Action.TARGET
	if action == Action.TARGET and event.is_action_released("target"):
		stop_dragging()
		command_units_to_target()
		action = Action.NONE

func _handle_snap_target_input(event: InputEvent) -> void:
	if action == Action.NONE and event.is_action_pressed("snap target"):
		begin_dragging()
		action = Action.SNAP_TARGET
	if action == Action.SNAP_TARGET and event.is_action_released("snap target"):
		stop_dragging()
		snap_targets()
		command_units_to_target()
		action = Action.NONE

func _handle_move_input(event: InputEvent) -> void:
	if action == Action.NONE and event.is_action_pressed("move"):
		begin_dragging()
		action = Action.MOVE
	if action == Action.MOVE and event.is_action_released("move"):
		command_units_to_stop()
		stop_dragging()
		command_units_to_move()
		action = Action.NONE

func _handle_queue_move_input(event: InputEvent) -> void:
	if action == Action.NONE and event.is_action_pressed("queue move"):
		begin_dragging()
		action = Action.QUEUE_MOVE
	if action == Action.QUEUE_MOVE and event.is_action_released("queue move"):
		stop_dragging()
		command_units_to_move()
		action = Action.NONE

func _handle_formation_input(event: InputEvent) -> void:
	if event.is_action_pressed("line formation"):
		formation = Formation.LINE
	elif event.is_action_pressed("v formation"):
		formation = Formation.V
	elif event.is_action_pressed("smooth formation"):
		formation = Formation.SMOOTH
	elif event.is_action_pressed("precise formation"):
		formation = Formation.PRECISE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	if event.is_action_pressed("select"):
		var unit := get_nearest_unit(get_global_mouse_position() )
		select_units( [unit] )
	if event.is_action_pressed("lock units"):
		toggle_units_movement_lock()
	if event.is_action_released("stop"):
		command_units_to_stop()
	_handle_move_input(event)
	_handle_queue_move_input(event)
	_handle_target_input(event)
	_handle_snap_target_input(event)
	_handle_formation_input(event)
