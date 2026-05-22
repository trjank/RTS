class_name PartSelection extends Draggable

@export var mouse_selection: MouseSelection
@export var mesh_instance: MeshInstance3D
@export var grid: Grid

const MAX_ROTATION_DURATION_SEC := 1.0

var _rotation_tween: Tween

static func is_part(node: Node) -> bool:
	return node is PartHitbox

func _ready() -> void:
	super()
	mesh_instance.mesh.size = Vector2(size.x, size.z)

func is_empty() -> bool:
	# Empty of parts if the only children are the mesh instance and collision shape
	return get_child_count() == 2

func set_size(new_size: Vector3) -> void:
	super(new_size)
	if not is_node_ready():
		return
	mesh_instance.mesh.size = Vector2(new_size.x, new_size.z)
	mesh_instance.set_instance_shader_parameter("size", mesh_instance.mesh.size)

func flip() -> void:
	scale.x = -scale.x

func smooth_rotate(radians: float, duration_sec := 0.2) -> void:
	snap_rotation()
	duration_sec = minf(duration_sec, MAX_ROTATION_DURATION_SEC)
	_rotation_tween = create_tween()
	_rotation_tween.tween_property(self, "rotation:y", rotation.y + radians, duration_sec).from_current()

func snap_rotation() -> void:
	if _rotation_tween != null:
		_rotation_tween.custom_step(MAX_ROTATION_DURATION_SEC)
	rotation.y = snappedf(rotation.y, Grid.ROTATION_INCREMENT)

func snap_to_grid() -> void:
	if not is_node_ready():
		return
	snap_rotation()
	size = size.snappedf(Grid.METERS_PER_TILE)
	var half_size := 0.5 * size * transform.basis
	position = half_size + (position - half_size).snappedf(Grid.METERS_PER_TILE)

func spawn_part(where: Vector3, part_data: PartData) -> PartHitbox:
	move_parts()
	var part := PartHitbox.create()
	var size_2d := Grid.METERS_PER_TILE * part_data.get_size()
	part.data = part_data
	size = Vector3(size_2d.x, 0.0, size_2d.y)
	scale.x = absf(scale.x)
	global_position = where
	rotation.y = 0.0
	add_child(part)
	part.selected.connect(select_part_and_drag.bind(part) )
	return part

func spawn_part_at_mouse(part_data: PartData) -> PartHitbox:
	return spawn_part(mouse_selection.get_mouse_position_3d(), part_data)

func begin_dragging() -> bool:
	if is_empty() or not super():
		return false
	# Need this because we are moving around internal nodes
	grid._update_error(Grid.RECALCULATE_ERROR)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	return true

func stop_dragging() -> bool:
	if not super():
		return false
	snap_to_grid()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return true

func add_part(node: Node) -> bool:
	var part := node as PartHitbox
	if part == null:
		return false
	part.reparent(self)
	part.overlapping = false
	return true

func move_parts() -> void:
	for node in get_children().filter(is_part):
		grid.add_part(node)
	size = Vector3.ZERO

func delete_parts() -> void:
	for node in get_children().filter(is_part):
		node.queue_free()
	size = Vector3.ZERO

func select_part(part: PartHitbox) -> bool:
	return select( [part], part.global_position, part.get_size_2d(), part.rotation.y)

func select_part_and_drag(part: PartHitbox) -> bool:
	return select_part(part) and begin_dragging()

func select(selection: Array[Node3D], at: Vector3, span: Vector2, y_rotation := 0.0) -> bool:
	move_parts()
	scale.x = absf(scale.x)
	rotation.y = y_rotation
	global_position = at
	size = Vector3(span.x, 0.0, span.y)
	snap_to_grid()
	return selection.all(add_part)

func copy_part(node: Node) -> bool:
	var part := node as PartHitbox
	if part == null:
		return false
	var new_part := PartHitbox.create()
	add_child(new_part)
	new_part.transform = part.transform
	new_part.data = part.data
	grid.add_part(new_part)
	return true

func copy_to(where: Vector3) -> void:
	get_children().all(copy_part)
	global_position = where
	snap_to_grid()

func _input(event: InputEvent) -> void:
	if event.is_action_released("delete"):
		delete_parts()
	elif event.is_action_pressed("copy"):
		copy_to(mouse_selection.get_mouse_position_3d() )
	elif is_dragging():
		_handle_drag_input(event)

func _handle_drag_input(event: InputEvent) -> void:
	if event.is_action_pressed("flip"):
		flip()
	if event.is_action_pressed("rotate cw"):
		smooth_rotate(-Grid.ROTATION_INCREMENT)
	if event.is_action_pressed("rotate ccw"):
		smooth_rotate(Grid.ROTATION_INCREMENT)
	if event.is_action_released("select"):
		stop_dragging()
