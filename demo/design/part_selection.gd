class_name PartSelection extends StaticBody3D

signal dragging_started
signal dragging_ended

const MAX_ROTATION_DURATION_SEC := 1.0

@export var rotation_duration_sec := 0.0
@export var rotation_ease := Tween.EASE_IN
@export var mouse_selection: MouseSelection
@export var mesh_instance: MeshInstance3D
@export var grid: Grid
@export var collision_shape: CollisionShape3D

var size_2d: Vector2:
	get = get_size_2d,
	set = set_size_2d
var size_3d := Vector3.ZERO:
	set = set_size_3d

var _rotation_tween: Tween
var _dragging := false
var _mouse_offset := Vector3.ZERO

static func is_part(node: Node) -> bool:
	return node is PartHitbox

func _ready() -> void:
	collision_layer = Globals.Layer.PARTS
	mouse_selection.collision_mask = Globals.Layer.PARTS
	size_3d = Vector3.ZERO

func is_dragging() -> bool:
	return _dragging

func is_empty() -> bool:
	return not get_children().any(is_part)

func get_size_2d() -> Vector2:
	return Vector2(size_3d.x, size_3d.z)

func set_size_2d(new_size_2d: Vector2) -> void:
	size_3d = Vector3(new_size_2d.x, size_3d.y, new_size_2d.y)

func set_size_3d(new_size_3d: Vector3) -> void:
	if not is_node_ready():
		return
	size_3d = new_size_3d
	collision_shape.shape.size = new_size_3d
	mesh_instance.mesh.size = Vector2(new_size_3d.x, new_size_3d.z)
	mesh_instance.set_instance_shader_parameter("size", mesh_instance.mesh.size)

func flip() -> void:
	scale.x = -scale.x

func reset_flip() -> void:
	scale.x = absf(scale.x)

func smooth_rotate(radians: float, duration_sec := rotation_duration_sec) -> void:
	snap_rotation()
	duration_sec = minf(duration_sec, MAX_ROTATION_DURATION_SEC)
	_rotation_tween = create_tween()
	_rotation_tween.tween_property(self, "rotation:y", rotation.y + radians, duration_sec).from_current().set_ease(rotation_ease)

func snap_rotation() -> void:
	if _rotation_tween != null:
		_rotation_tween.custom_step(MAX_ROTATION_DURATION_SEC)
	rotation.y = snappedf(rotation.y, Rotation.INCREMENT)

func snap_to_grid() -> void:
	if not is_node_ready():
		return
	snap_rotation()
	size_3d = size_3d.snappedf(Measurement.METERS_PER_TILE)
	var half_size := 0.5 * size_3d * transform.basis
	position = half_size + (position - half_size).snappedf(Measurement.METERS_PER_TILE)

func spawn_part(center: Vector3, part_data: PartData) -> PartHitbox:
	var part := PartHitbox.create()
	var span := Measurement.METERS_PER_TILE * part_data.get_size()
	part.data = part_data
	_reset(center, span)
	add_child(part)
	return part

func spawn_part_at_mouse(part_data: PartData) -> PartHitbox:
	return spawn_part(mouse_selection.get_mouse_position_3d(), part_data)

func begin_dragging() -> void:
	if _dragging and not is_empty():
		return
	grid.force_recalculate_error()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_mouse_offset = global_position - mouse_selection.get_mouse_position_3d()
	_dragging = true
	dragging_started.emit()

func stop_dragging() -> void:
	if not _dragging:
		return
	snap_to_grid()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_dragging = false
	dragging_ended.emit()

func add_part(part: PartHitbox) -> void:
	if part == null:
		return
	part.reparent(self)
	part.overlapping = false

func move_parts() -> void:
	for node in get_children().filter(is_part):
		grid.add_part(node)
	size_3d = Vector3.ZERO

func delete_parts() -> void:
	for node in get_children().filter(is_part):
		node.queue_free()
	size_3d = Vector3.ZERO

func select(selection: Array[Node3D], center: Vector3, span: Vector2) -> bool:
	_reset(center, span)
	snap_to_grid()
	#
	for node in selection:
		add_part(node as PartHitbox)
	return true

func copy_to(where: Vector3) -> void:
	for node in get_children():
		copy_part(node as PartHitbox)
	global_position = where
	snap_to_grid()

func copy_part(part: PartHitbox) -> void:
	if part == null:
		return
	var new_part := PartHitbox.create()
	add_child(new_part)
	new_part.transform = part.transform
	new_part.data = part.data
	grid.add_part(new_part)

func _reset(center := Vector3.ZERO, span := Vector2.ZERO) -> void:
	move_parts()
	reset_flip()
	rotation.y = 0.0
	global_position = center
	size_2d = span

func _physics_process(_dt: float) -> void:
	if _dragging:
		global_position = _mouse_offset + mouse_selection.get_mouse_position_3d()

func _input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		stop_dragging()
	if event.is_action_released("delete"):
		delete_parts()
	elif event.is_action_pressed("copy"):
		copy_to(mouse_selection.get_mouse_position_3d() )
	elif is_dragging():
		_handle_drag_input(event)

func _handle_drag_input(event: InputEvent) -> void:
	if event.is_action_pressed("flip"):
		flip()
	if event.is_action_pressed("rotate clockwise"):
		smooth_rotate(-Rotation.INCREMENT)
	if event.is_action_pressed("rotate counterclockwise"):
		smooth_rotate(Rotation.INCREMENT)
	if event.is_action_released("select"):
		stop_dragging()

func _on_mouse_selection_selected_single(node: Node3D, center: Vector3) -> void:
	if node == null:
		return _reset()
	if node != self and not is_ancestor_of(node):
		select( [node], center, Measurement.METERS_PER_TILE * Vector2.ONE)
	begin_dragging()

func _on_mouse_selection_selected_multiple(nodes: Array[Node3D], center: Vector3, span: Vector2) -> void:
	select(nodes, center, span)

func _on_mouse_selection_selection_started() -> void:
	move_parts()
