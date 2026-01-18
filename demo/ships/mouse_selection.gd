class_name MouseSelection extends Area2D

signal selection_started
signal selection_ended
signal selected(bodies: Array[Node2D], rect: Rect2)

@export var color: Color
@export var hitbox: CollisionShape2D

var _rect := Rect2()

static func z_sorter(a: Node2D, b: Node2D) -> bool:
	assert(not a.z_as_relative and not b.z_as_relative)
	return a.z_index > b.z_index

static func distance_sorter(a: Node2D, b: Node2D, from: Vector2) -> bool:
	return a.global_position.distance_squared_to(from) > b.global_position.distance_squared_to(from)

func _ready() -> void:
	_rect.size = Vector2.ZERO
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

func _to_collider(result: Dictionary) -> Node2D:
	return result["collider"]

func sorted_query(where: Vector2, sorter := z_sorter, max_distance := 0.0, max_results := 32) -> Array:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	# A circle should be sufficient for most applications
	query.transform = Transform2D(0.0, where)
	query.collision_mask = collision_mask
	query.shape = shape
	shape.radius = max_distance
	# NOTE: Ensure collision_mask is correctly set!
	var results := get_world_2d().direct_space_state.intersect_shape(query, max_results)
	var nodes := results.map(_to_collider)
	if sorter != null:
		nodes.sort_custom(sorter)
	return nodes

func _resize_hitbox() -> void:
	global_scale = Vector2.ONE
	global_rotation = 0.0
	hitbox.shape.size = _rect.size.abs()
	queue_redraw()

func _begin_selection() -> void:
	_rect.position = get_global_mouse_position()
	_resize_hitbox()
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	selection_started.emit()

func _stop_selection() -> void:
	_rect.size = Vector2.ZERO
	_resize_hitbox()
	set_physics_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	selection_ended.emit()

func _draw() -> void:
	draw_rect(hitbox.shape.get_rect(), color)

func _physics_process(_dt: float) -> void:
	_rect.end = get_global_mouse_position()
	global_position = _rect.get_center()
	_resize_hitbox()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("multiselect") and not is_selecting():
		_begin_selection()
	if event.is_action_released("multiselect") and is_selecting():
		selected.emit(get_overlapping_bodies(), _rect.abs() )
		_stop_selection()
