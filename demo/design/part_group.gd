class_name PartGroup extends Sprite2D

signal dragging_started
signal dragging_ended

@export var mouse_selection: MouseSelection
@export var grid: Grid

const MOUSE_QUERY_RANGE := 0.0
const MOUSE_QUERY_MAX_DEPTH := 32

var _mouse_offset := Vector2.ZERO

func contains_mouse() -> bool:
	return get_rect().has_point(get_local_mouse_position() )

func is_dragging() -> bool:
	return is_processing()

func is_empty() -> bool:
	return get_child_count() == 0

func _ready() -> void:
	set_process(false)

func smooth_rotate(radians: float, duration_sec := 0.15) -> void:
	create_tween().tween_property(self, "rotation", rotation + radians, duration_sec)

func snap_rotation() -> void:
	rotation = snappedf(rotation, PI/2)

func snap_to_grid() -> void:
	snap_rotation()
	var rect := transform * get_rect()
	rect.position = rect.position.snappedf(Grid.TILE_SIZE)
	rect.end = rect.end.snappedf(Grid.TILE_SIZE)
	position = rect.get_center()
	region_rect.size = (rect * transform).size

func spawn_part(where: Vector2, part_data: PartData) -> PartHitbox:
	var successful_move := move_parts()
	assert(successful_move)
	var part := PartHitbox.create()
	part.data = part_data
	region_rect.size = part.get_size()
	scale.x = absf(scale.x)
	position = where
	rotation = 0.0
	add_child(part)
	return part

func spawn_part_at_mouse(part_data: PartData) -> PartHitbox:
	return spawn_part(transform * get_local_mouse_position(), part_data)

func begin_dragging() -> void:
	_mouse_offset = get_global_mouse_position() - global_position
	set_process(true)
	dragging_started.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func stop_dragging() -> void:
	snap_to_grid()
	set_process(false)
	dragging_ended.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func add_part(part: Node) -> bool:
	part.reparent(self)
	return part is PartHitbox

func delete_part(part: Node) -> bool:
	part.queue_free()
	return part is PartHitbox

func move_parts() -> bool:
	region_rect.size = Vector2.ZERO
	return get_children().all(grid.add_part)

func delete_parts() -> bool:
	region_rect.size = Vector2.ZERO
	return get_children().all(delete_part)

func select_part(part: PartHitbox) -> bool:
	return select( [part], part.get_global_rect())

func select_part_at(where: Vector2) -> bool:
	var parts := mouse_selection.sorted_query(
		where,
		MouseSelection.z_sorter,
		MOUSE_QUERY_RANGE,
		MOUSE_QUERY_MAX_DEPTH
	)
	return not parts.is_empty() and select_part(parts[0] )

func select(selection: Array[Node2D], global_rect: Rect2) -> bool:
	var successful_move := move_parts()
	scale.x = absf(scale.x)
	global_rotation = 0.0
	global_position = global_rect.get_center()
	region_rect.size = global_rect.size / global_scale
	snap_to_grid()
	return successful_move and selection.all(add_part)

func copy_part(node: Node) -> bool:
	var part := node as PartHitbox
	if part == null:
		return false
	var new_part := PartHitbox.create()
	add_child(new_part)
	new_part.transform = part.transform
	new_part.data = part.data
	return grid.add_part(new_part)

func copy_to(where: Vector2) -> void:
	get_children().all(copy_part)
	global_position = where
	snap_to_grid()
	#var copy := duplicate() as PartGroup
	#add_sibling(copy)
	#copy.position = position
	#var x := get_child(0) as PartHitbox
	#print(x.duplicate().data)
	##copy.move_parts()
	##copy.queue_free()
	#global_position = where
	#snap_to_grid()

func _process(_dt: float) -> void:
	global_position = get_global_mouse_position() - _mouse_offset

func _input(event: InputEvent) -> void:
	var mouse := get_global_mouse_position()
	if event.is_action_released("delete"):
		delete_parts()
	elif event.is_action_pressed("copy"):
		copy_to(mouse)
	elif is_dragging():
		_handle_drag_input(event)
	elif event.is_action_pressed("select") and contains_mouse() and not is_empty():
		begin_dragging()
	elif event.is_action_pressed("select") and select_part_at(mouse):
		begin_dragging()

func _handle_drag_input(event: InputEvent) -> void:
	if event.is_action_pressed("flip"):
		scale.x = -scale.x
	if event.is_action_pressed("rotate cw"):
		snap_rotation()
		smooth_rotate(PI/2)
	if event.is_action_pressed("rotate ccw"):
		snap_rotation()
		smooth_rotate(-PI/2)
	if event.is_action_released("select"):
		stop_dragging()
