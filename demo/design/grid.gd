class_name Grid extends Sprite2D

signal ship_changed(grid: Grid)
signal save_changed(saved: bool)

const TILE_SIZE := 32.0
const RECALCULATE_ERROR := -1

var _parts: Node2D
var _parts_cache: Dictionary[ShipData, Node2D] = {}
var _error_cache: Dictionary[ShipData, int] = {}

var size: Vector2i:
	set = set_size
var ship_data: ShipData:
	set = set_ship_data

func _ready() -> void:
	region_enabled = true
	ship_data = ShipData.new(32, 32)

func is_saved() -> bool:
	return _error_cache[ship_data] == ShipData.PartError.OK

func set_size(new_size: Vector2i) -> void:
	size = new_size
	region_rect.size = TILE_SIZE * size

func set_ship_data(new_ship_data: ShipData) -> bool:
	if ship_data == new_ship_data:
		return true
	if new_ship_data == null:
		return false
	_clear_ship()
	ship_data = new_ship_data
	size = ship_data.get_grid_rect().size
	_load_ship()
	ship_changed.emit(self)
	return true

func is_cached(data := ship_data) -> bool:
	return data in _parts_cache

func cache() -> void:
	_parts_cache[ship_data] = _parts

func uncache(data := ship_data) -> bool:
	return _parts_cache.erase(data)

func clear_cache() -> void:
	for parts in _parts_cache.values():
		parts.queue_free()
	_parts_cache.clear()

func _update_error(error: int) -> void:
	var was_saved := not ship_data in _error_cache or is_saved()
	_error_cache[ship_data] = error
	var saved := is_saved()
	if was_saved != saved:
		save_changed.emit(saved)

func add_part(part: Node) -> bool:
	if not part is PartHitbox:
		return false
	part.reparent(_parts)
	_update_error(RECALCULATE_ERROR)
	return true

func create_part(where: Vector2, part_data: PartData, placement := PartImage.Placement.ROT_0) -> Part:
	var part := part_data.create_part()
	_parts.add_child(part)
	part.placement = placement
	part.position = where
	_update_error(RECALCULATE_ERROR)
	return part

func save(lazy := true) -> int:
	var error := _error_cache[ship_data]
	if lazy and error != RECALCULATE_ERROR:
		return error
	ship_data.clear()
	error = ShipData.PartError.OK
	for node in _parts.get_children():
		error |= _save_part(node)
	_update_error(error)
	return error

func _save_part(node: Node) -> ShipData.PartError:
	var part := node as PartHitbox
	if part == null:
		return ShipData.PartError.IS_NULL
	var error := ship_data.add_part(part.data, part.get_top_left_corner(), part.placement)
	part.overlapping = error == ShipData.PartError.OVERLAP
	return error

func sync() -> void:
	if _parts != null:
		_parts.queue_free()
	_parts = Node2D.new()
	add_child(_parts, false, INTERNAL_MODE_BACK)
	_parts_cache.erase(ship_data)
	ship_data.for_each_part(_load_part)
	_update_error(ShipData.PartError.OK)

func _load_part(ship_part: ShipDataPart) -> void:
	var part := PartHitbox.create()
	_parts.add_child(part)
	part.placement = ship_part.placement
	part.position = ship_part.get_center()

func _clear_ship() -> void:
	if ship_data in _parts_cache:
		_parts.hide()
		_parts.process_mode = Node.PROCESS_MODE_DISABLED
	elif _parts != null:
		_parts.queue_free()
		_error_cache.erase(ship_data)
	_parts = null

func _load_ship() -> void:
	if not ship_data in _parts_cache:
		return sync()
	_parts = _parts_cache[ship_data]
	_parts.show()
	_parts.process_mode = Node.PROCESS_MODE_INHERIT
