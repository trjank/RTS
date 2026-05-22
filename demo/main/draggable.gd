class_name Draggable extends StaticBody3D

signal dragging_started
signal dragging_ended

@export var collision_shape: CollisionShape3D
@export var size := Vector3.ZERO:
	set = set_size
@export var plane := Plane.PLANE_XZ:
	set = set_plane
@export var enabled := true:
	set = set_enabled

var _mouse_offset := Vector3.ZERO
var _dragging := false
var _box_shape := BoxShape3D.new()

func _ready() -> void:
	collision_shape.shape = _box_shape
	set_physics_process(false)

func is_dragging() -> bool:
	return _dragging

func get_mouse_position_3d() -> Vector3:
	return MouseSelection.get_node_mouse_position_3d(self, plane)

func set_size(new_size: Vector3) -> void:
	size = new_size
	_box_shape.size = new_size

func set_enabled(is_enabled: bool) -> void:
	if enabled and not is_enabled:
		stop_dragging()
	enabled = is_enabled
	input_ray_pickable = is_enabled

func set_plane(new_plane: Plane) -> void:
	stop_dragging()
	plane = new_plane

func begin_dragging() -> bool:
	if _dragging:
		return false
	_mouse_offset = global_position - get_mouse_position_3d()
	_dragging = true
	set_physics_process(true)
	dragging_started.emit()
	return true

func stop_dragging() -> bool:
	if not _dragging:
		return false
	set_physics_process(false)
	_dragging = false
	dragging_ended.emit()
	return true

func _physics_process(_dt: float) -> void:
	assert(_dragging)
	#
	global_position = get_mouse_position_3d() + _mouse_offset

func _input_event(_camera: Camera3D, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("select"):
		begin_dragging()
	if Input.is_action_just_released("select"):
		stop_dragging()
