class_name UnitFormation extends Node3D

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
const MOUSE_CURSOR_CENTER := Vector2(16.0, 16.0)
const MAX_SELECTION_DISTANCE := 100.0
const MAX_CLEANUP_ITERATIONS := 10

const _UNSTABLE_CURVE_LENGTH := 0.3
const _NO_DIV_ZERO := 0.001

@export var mouse_selection: MouseSelection
@export var multimesh_instance: MultiMeshInstance3D

var action := Action.NONE:
	set = set_action
var formation := Formation.LINE:
	set = set_formation

var _targets: Array[Target] = []
var _units: Array[RadarSignature] = []
var _sort_axis := Vector3.RIGHT
var _center_targets := Vector3.ZERO
var _center_units := Vector3.ZERO
var _curve_points := PackedVector3Array()
var _curve_length := 0.0

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
	begin_curve(mouse_selection.get_mouse_position_3d() )
	set_process(true)

func stop_dragging() -> void:
	set_process(false)
	end_curve()
	mouse_selection.enable()

func begin_curve(start: Vector3) -> void:
	_curve_length = 0.0
	_curve_points.resize(int(formation) )
	_curve_points.fill(start)
	#
	multimesh_instance.multimesh.instance_count = _targets.size()
	multimesh_instance.multimesh.visible_instance_count = -1
	var start_transform := Transform3D(Basis.IDENTITY, start)
	#
	for i in _targets.size():
		_targets[i] = Target.new(start)
		multimesh_instance.multimesh.set_instance_transform(i, start_transform)

func _interpolate_curve(index: float) -> Vector3:
	var i := int(floor(clampf(index, 0.0, _curve_points.size() - 2) ) )
	var start := _curve_points[i]
	var end := _curve_points[i + 1]
	return start.lerp(end, minf(index - i, 1.0) )

func move_curve(new_endpoint: Vector3) -> void:
	var old_length := _curve_length
	_curve_length += _curve_points[-1].distance_to(new_endpoint)
	_curve_points[-1] = new_endpoint
	#
	if _curve_length <= _UNSTABLE_CURVE_LENGTH:
		return
	var length_ratio := _curve_length / old_length
	var targets_step := (_curve_points.size() - 1) / (_targets.size() - 1 + _NO_DIV_ZERO)
	#
	for i in range(1, _curve_points.size() - 1):
		_curve_points[i] = _interpolate_curve(i * length_ratio)
	for i in _targets.size():
		_targets[i].global_position = _interpolate_curve(i * targets_step)
		multimesh_instance.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, _targets[i].global_position) )

func end_curve() -> void:
	_center_units = calculate_center(_units, _center_calculation_units)
	_center_targets = calculate_center(_targets, _center_calculation_targets)
	_sort_axis = _center_targets - _center_units
	multimesh_instance.multimesh.visible_instance_count = 0
	# Sort to get a decent low-intersection solution, and then iteratively improve on it
	_units.sort_custom(_axis_sorter_units)
	_targets.sort_custom(_axis_sorter_targets)
	cleanup_path_intersections()

func calculate_center(objects: Array, calculation: Callable) -> Vector3:
	return objects.reduce(calculation, Vector3.ZERO) / objects.size()

func _center_calculation_targets(sum: Vector3, unit: Target) -> Vector3:
	return sum + unit.global_position

func _center_calculation_units(sum: Vector3, unit: RadarSignature) -> Vector3:
	return sum + unit.get_future_global_position()

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

func _project(point: Vector3) -> Vector2:
	return Vector2(point.x, point.z)

func _do_paths_intersect(i: int, j: int) -> bool:
	var from_i := _project(_units[i].get_future_global_position() )
	var from_j := _project(_units[j].get_future_global_position() )
	var to_i := _project(_targets[i].global_position)
	var to_j := _project(_targets[j].global_position)
	return Geometry2D.segment_intersects_segment(from_i, to_i, from_j, to_j) != null

func get_nearest_unit(point: Vector3) -> RadarSignature:
	var unit := mouse_selection.get_nearest_node(point, Globals.Layer.UNITS, MAX_SELECTION_DISTANCE)
	return unit.get_radar_signature() if unit is Unit else null

func snap_targets() -> void:
	for i in _targets.size():
		_targets[i] = get_nearest_unit(_targets[i].global_position)

func _snap_target_to_nearest_unit(i: int) -> void:
	_targets[i] = get_nearest_unit(_targets[i].position)

func _axis_sorter_units(a: RadarSignature, b: RadarSignature) -> bool:
	var a_offset := a.get_future_global_position() - _center_units
	var b_offset := b.get_future_global_position() - _center_units
	return a_offset.cross(_sort_axis) < b_offset.cross(_sort_axis)

func _axis_sorter_targets(a: Target, b: Target) -> bool:
	var a_offset := a.global_position - _center_targets
	var b_offset := b.global_position - _center_targets
	return a_offset.cross(_sort_axis) < b_offset.cross(_sort_axis)

func _on_mouse_selection_selected(bodies: Array[Node3D], _center: Vector3, _span: Vector2) -> void:
	select_units(bodies.map(Unit.to_radar_signature) )

func _process(_dt: float) -> void:
	move_curve(mouse_selection.get_mouse_position_3d() )

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
	if event.is_action_pressed("lock units"):
		toggle_units_movement_lock()
	if event.is_action_released("stop"):
		command_units_to_stop()
	_handle_move_input(event)
	_handle_queue_move_input(event)
	_handle_target_input(event)
	_handle_snap_target_input(event)
	_handle_formation_input(event)
