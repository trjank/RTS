class_name UnitFormation extends Path2D

enum Formation {
	LINE = 2,
	V = 3,
	SMOOTH = 10,
	PRECISE = 30
}

const MAX_CLEANUP_ITERATIONS := 10
const UNSTABLE_CURVE_LENGTH := 0.1
const PREVENT_DIV_ZERO := 0.001

@export var formation := Formation.LINE
@export var target_draw_size := 100.0
@export var target_draw_color := Color.WHITE

var targets: Array[Target] = []
var units: Array[RadarSignature] = []
var search_shape := CircleShape2D.new()

var _sort_axis := Vector2.RIGHT
var _center_targets := Vector2.ZERO
var _center_units := Vector2.ZERO

static func is_unit_locked(unit: RadarSignature) -> bool:
	return unit.is_alive() and unit.as_unit().movement_locked

# NOTE: Pass this function to command_units (you may need to bind lock_units)
static func movement_lock_command(unit: RadarSignature, _target: Target, lock_units := true) -> void:
	unit.as_unit().movement_locked = lock_units

# NOTE: Pass this function to command_units
static func target_command(unit: RadarSignature, target: Target) -> void:
	unit.as_unit().target(target)

# NOTE: Pass this function to command_units
static func move_command(unit: RadarSignature, target: Target) -> void:
	unit.as_unit().queue_waypoint(target)

func command_units(command: Callable) -> void:
	assert(units.size() == targets.size() )
	#
	for i in units.size():
		if units[i].is_alive():
			command.call(units[i], targets[i])

func toggle_units_movement_lock(threshold := 0.5) -> void:
	assert(0.0 <= threshold and threshold <= 1.0)
	#
	var num_locked := units.filter(is_unit_locked).size()
	var lock_units := num_locked <= threshold * units.size()
	command_units(movement_lock_command.bind(lock_units) )

func begin_curve(start: Vector2) -> void:
	curve.clear_points()
	targets.clear()
	for i in int(formation):
		curve.add_point(start)
	for i in units.size():
		targets.push_back(Target.new(start) )

func move_curve(new_endpoint: Vector2) -> void:
	var length := curve.get_baked_length()
	curve.set_point_position(-1, new_endpoint)
	if length <= UNSTABLE_CURVE_LENGTH:
		return
	var targets_step := length / (targets.size() - 1 + PREVENT_DIV_ZERO)
	var segment_length := length / (curve.point_count - 1)
	for i in range(1, curve.point_count - 1):
		curve.set_point_position(i, curve.sample_baked(i * segment_length))
	for i in targets.size():
		targets[i].position = curve.sample_baked(i * targets_step)

func end_curve() -> void:
	calculate_center_units()
	calculate_center_targets()
	_sort_axis = _center_targets - _center_units
	units.sort_custom(unit_axis_sorter)
	targets.sort_custom(target_axis_sorter)
	cleanup_path_intersections()

func paths_intersect(i: int, j: int) -> bool:
	return Geometry2D.segment_intersects_segment(
		units[i].future_position,
		targets[i].position,
		units[j].future_position,
		targets[j].position
	)

func _swap_path_endpoints(i: int, j: int) -> bool:
	if not paths_intersect(i, j):
		return false
	var temp := targets[i]
	targets[i] = targets[j]
	targets[j] = temp
	return true

func _path_cleanup_iteration() -> bool:
	var swapped := false
	for i in targets.size() - 1:
		swapped = swapped or _swap_path_endpoints(i, i + 1)
	return swapped

func cleanup_path_intersections() -> int:
	var swapped := true
	var iteration := 0
	while swapped and iteration < MAX_CLEANUP_ITERATIONS:
		swapped = _path_cleanup_iteration()
		iteration += 1
	return iteration

func snap_targets() -> void:
	for i in targets.size():
		var nearest := get_nearest_unit(targets[i].position, 0)
		if nearest != null:
			targets[i] = nearest.get_radar_signature()

func get_nearest_unit(from_position: Vector2, collision_mask: int) -> Unit:
	assert(search_shape.radius > 0)
	#
	var physics := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.collision_mask = collision_mask
	query.shape = search_shape
	query.transform = Transform2D(0.0, from_position)
	var colliders := physics.intersect_shape(query, 1)
	return null if colliders.is_empty() else (colliders[0].collider as Unit)

func _center_calculation(sum: Vector2, unit: RadarSignature) -> Vector2:
	# NOTE: You can factor in mass here, but it is unecessary for most situations
	return sum + unit.future_position

func _draw() -> void:
	for target in targets:
		draw_circle(target.position, target_draw_size, target_draw_color)

func calculate_center_units() -> void:
	_center_units = units.reduce(_center_calculation, Vector2.ZERO) / units.size()

func calculate_center_targets() -> void:
	_center_targets = 0.5 * (curve.sample_baked(0.33) + curve.sample_baked(0.66) )

func unit_axis_sorter(a: RadarSignature, b: RadarSignature) -> bool:
	var a_offset := a.future_position - _center_units
	var b_offset := b.future_position - _center_units
	return a_offset.cross(_sort_axis) < b_offset.cross(_sort_axis)

func target_axis_sorter(a: Target, b: Target) -> bool:
	var a_offset := a.position - _center_targets
	var b_offset := b.position - _center_targets
	return a_offset.cross(_sort_axis) < b_offset.cross(_sort_axis)

func _on_mouse_selection_selected(bodies: Array[Node2D], _rect: Rect2) -> void:
	#deselect
	units.clear()
	#select
