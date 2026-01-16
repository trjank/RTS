class_name Grid extends Sprite2D

signal ship_changed(grid: Grid)

const TILE_SIZE := 32.0

var _parts: Node2D
var _parts_cache: Dictionary[ShipData, Node2D] = {}

var size: Vector2i:
	set = set_size
var ship: ShipData:
	set = set_ship

func _ready() -> void:
	region_enabled = true
	ship = ShipData.new(32, 32)

func set_size(new_size: Vector2i) -> void:
	size = new_size
	region_rect.size = TILE_SIZE * size

func is_cached(data := ship) -> bool:
	return data in _parts_cache

func cache() -> void:
	_parts_cache[ship] = _parts

func uncache(data := ship) -> bool:
	return _parts_cache.erase(data)

func clear_cache() -> void:
	_parts_cache.clear()

func add_part(part: Node) -> bool:
	part.reparent(_parts)
	return part is PartHitbox

func create_part(where: Vector2, part_data: PartData, placement := PartImage.Placement.ROT_0) -> Part:
	var part := part_data.create_part()
	_parts.add_child(part)
	part.placement = placement
	part.position = where
	return part

func load_part(ship_part: ShipDataPart) -> bool:
	if ship_part == null:
		return true
	var part := ship_part.get_data().create_part()
	_parts.add_child(part)
	part.placement = ship_part.placement
	part.position = ship_part.get_center()
	return PartImage.is_placement_valid(ship_part.placement)

func save_part(node: Node) -> ShipData.PartError:
	var part := node as PartHitbox
	if part == null:
		return ShipData.PartError.IS_NULL
	var error := ship.add_part(
		part.data,
		part.get_top_left_corner(),
		part.get_placement()
	)
	part.overlapping = error == ShipData.PartError.OVERLAP
	return error

func save() -> int:
	ship.clear()
	var error: int = ShipData.PartError.OK
	for node in _parts.get_children():
		error |= save_part(node)
	return error

func sync() -> bool:
	if _parts != null:
		_parts.queue_free()
	_parts = Node2D.new()
	_parts_cache.erase(ship)
	add_child(_parts, false, INTERNAL_MODE_BACK)
	return ship._parts.all(load_part)

func set_ship(new_ship: ShipData) -> bool:
	if ship == new_ship:
		return true
	if new_ship == null:
		return false
	_clear_ship()
	ship = new_ship
	size = ship.get_grid_rect().size
	var success := _load_ship()
	ship_changed.emit(self)
	return success

func _clear_ship() -> void:
	if ship in _parts_cache:
		_parts.hide()
		_parts.process_mode = Node.PROCESS_MODE_DISABLED
	elif _parts != null:
		_parts.queue_free()
	_parts = null

func _load_ship() -> bool:
	if not ship in _parts_cache:
		return sync()
	_parts = _parts_cache[ship]
	_parts.show()
	_parts.process_mode = Node.PROCESS_MODE_INHERIT
	return true
