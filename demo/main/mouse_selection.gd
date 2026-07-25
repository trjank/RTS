class_name MouseSelection extends Area3D

signal selection_started
signal selection_ended
signal selected(nodes: Array[Node3D], center: Vector3, span: Vector2)
signal selected_multiple(nodes: Array[Node3D], center: Vector3, span: Vector2)
signal selected_single(node: Node3D, center: Vector3)
signal mouse_moved(new_position: Vector3)

enum SingleSelectMode {
	DISABLED,
	TOP_NODE,
	NEAREST_NODE
}

const Y_RANGE := 100.0

@export var single_select_range := 1.0
@export var single_select_mode := SingleSelectMode.DISABLED
@export var hitbox: CollisionShape3D
@export var raycast: RayCast3D
@export var mesh_instance: MeshInstance3D

var plane := Plane.PLANE_XZ:
	set = set_plane
var start := Vector3.ZERO
var end := Vector3.ZERO

var _mouse_position_3d := Vector3.ZERO
var _selecting := false

static func distance_sorter(a: Node3D, b: Node3D, point: Vector3) -> bool:
	return a.global_position.distance_squared_to(point) < b.global_position.distance_squared_to(point)

static func get_node_mouse_position_3d(node: Node3D, mouse_plane: Plane) -> Vector3:
	var mouse_position := node.get_viewport().get_mouse_position()
	var camera := node.get_viewport().get_camera_3d()
	var ray_from := camera.project_ray_origin(mouse_position)
	var ray_dir := camera.project_ray_normal(mouse_position)
	# Return a point on the plane
	return mouse_plane.intersects_ray(ray_from, ray_dir)

static func _to_collider(result: Dictionary) -> Node3D:
	return result["collider"]

func _ready() -> void:
	mesh_instance.mesh.size = Vector2.ZERO
	_resize_hitbox()

func is_selecting() -> bool:
	return _selecting

func is_enabled() -> bool:
	return is_processing_unhandled_input()

func enable() -> void:
	set_process_unhandled_input(true)

func disable() -> void:
	set_process_unhandled_input(false)
	_stop_selection()

func set_plane(new_plane: Plane) -> void:
	_stop_selection()
	plane = new_plane
	_resize_hitbox()

func get_mouse_position_3d() -> Vector3:
	return _mouse_position_3d

func get_nearest_nodes(point: Vector3, mask := globals.Layer.EVERYTHING, max_distance := single_select_range) -> Array:
	var shape := SphereShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	shape.radius = max_distance
	query.shape = shape
	query.transform = Transform3D(Basis(), point)
	query.collision_mask = mask
	# NOTE: This only checks 32 nodes by default (set max_results to change this)
	return get_world_3d().direct_space_state.intersect_shape(query).map(_to_collider)

func get_nearest_node(point: Vector3, mask := globals.Layer.EVERYTHING, max_distance := single_select_range) -> Node3D:
	var nodes := get_nearest_nodes(point, mask, max_distance)
	nodes.sort_custom(distance_sorter.bind(point) )
	return null if nodes.is_empty() else nodes[0]

func get_top_node(point: Vector3, mask := globals.Layer.EVERYTHING) -> Node3D:
	raycast.global_position = point
	raycast.collision_mask = mask
	raycast.force_raycast_update()
	return raycast.get_collider() as Node3D

func get_mouse_node() -> Node3D:
	var select_top := single_select_mode == SingleSelectMode.TOP_NODE
	return get_top_node(_mouse_position_3d, collision_mask) if select_top else get_nearest_node(_mouse_position_3d, collision_mask, single_select_range)

func _resize_hitbox() -> void:
	var size_3d := (to_local(end) - to_local(start) ).abs()
	var size_2d := Vector2(size_3d.x, size_3d.z)
	size_3d.y = Y_RANGE
	global_position = 0.5 * (start + end)
	mesh_instance.mesh.size = size_2d
	mesh_instance.set_instance_shader_parameter("size", size_2d)
	hitbox.shape.size = size_3d

func _begin_selection() -> void:
	if _selecting:
		return
	start = _mouse_position_3d
	end = start
	_resize_hitbox()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_selecting = true
	selection_started.emit()

func _move_selection() -> void:
	if not _selecting:
		return
	end = _mouse_position_3d
	_resize_hitbox()

func _stop_selection() -> void:
	if not _selecting:
		return
	mesh_instance.mesh.size = Vector2.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_selecting = false
	selection_ended.emit()

func _physics_process(_dt: float) -> void:
	# Since the camera may change position, this cannot go in _input or _unhandled_input
	_mouse_position_3d = get_node_mouse_position_3d(self, plane)
	mouse_moved.emit(_mouse_position_3d)
	_move_selection()

func _finish_single_selection() -> void:
	var mouse_node := get_mouse_node()
	var mouse_nodes := [mouse_node] as Array[Node3D] if mouse_node != null else ( [] as Array[Node3D] )
	selected.emit(mouse_nodes, _mouse_position_3d, Vector2.ZERO)
	selected_single.emit(mouse_node, _mouse_position_3d)

func _finish_multiselection() -> void:
	var nodes := get_overlapping_bodies()
	var span: Vector2 = mesh_instance.mesh.size
	selected.emit(nodes, global_position, span)
	selected_multiple.emit(nodes, global_position, span)
	_stop_selection()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and single_select_mode != SingleSelectMode.DISABLED:
		_finish_single_selection()
	if event.is_action_pressed("multiselect") and not _selecting:
		_begin_selection()
	if event.is_action_released("multiselect") and _selecting:
		_finish_multiselection()
