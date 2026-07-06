class_name MouseSelection extends Area3D

signal selection_started
signal selection_ended
signal selected(bodies: Array[Node3D], center: Vector3, span: Vector2)

const VERTICAL_RANGE := 100.0

@export var hitbox: CollisionShape3D
@export var raycast: RayCast3D
@export var mesh_instance: MeshInstance3D

var plane := Plane.PLANE_XZ:
	set = set_plane
var start := Vector3.ZERO
var end := Vector3.ZERO

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
	set_physics_process(false)

func is_selecting() -> bool:
	return is_physics_processing()

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

func get_nearest_nodes(point: Vector3, mask := globals.Layer.EVERYTHING, max_distance := 1.0) -> Array:
	var shape := SphereShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	shape.radius = max_distance
	query.shape = shape
	query.transform = Transform3D(Basis(), point)
	query.collision_mask = mask
	# NOTE: This only checks 32 nodes by default (set max_results to change this)
	return get_world_3d().direct_space_state.intersect_shape(query).map(_to_collider)

func get_nearest_node(point: Vector3, mask := globals.Layer.EVERYTHING, max_distance := 1.0) -> Node3D:
	var nodes := get_nearest_nodes(point, mask, max_distance)
	nodes.sort_custom(distance_sorter.bind(point) )
	return null if nodes.is_empty() else nodes[0]

func get_mouse_position_3d() -> Vector3:
	return get_node_mouse_position_3d(self, plane)

func get_top_node(point: Vector3, mask := globals.Layer.EVERYTHING) -> Node3D:
	raycast.global_position = point
	raycast.collision_mask = mask
	raycast.force_raycast_update()
	return raycast.get_collider() as Node3D

func _resize_hitbox() -> void:
	var size_3d := (to_local(end) - to_local(start) ).abs()
	var size_2d := Vector2(size_3d.x, size_3d.z)
	size_3d.y = VERTICAL_RANGE
	global_position = 0.5 * (start + end)
	mesh_instance.mesh.size = size_2d
	mesh_instance.set_instance_shader_parameter("size", size_2d)
	hitbox.shape.size = size_3d

func _begin_selection() -> void:
	if is_selecting():
		return
	start = get_mouse_position_3d()
	end = start
	_resize_hitbox()
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	selection_started.emit()

func _stop_selection() -> void:
	if not is_selecting():
		return
	set_physics_process(false)
	mesh_instance.mesh.size = Vector2.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	selection_ended.emit()

func _physics_process(_dt: float) -> void:
	end = get_mouse_position_3d()
	_resize_hitbox()
 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("multiselect") and not is_selecting():
		_begin_selection()
	if event.is_action_released("multiselect") and is_selecting():
		selected.emit(get_overlapping_bodies(), global_position, mesh_instance.mesh.size)
		_stop_selection()
