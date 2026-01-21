class_name Grid extends Sprite2D

signal ship_changed(grid: Grid)
signal save_changed(some_ship: ShipData, saved: bool)

const TILE_SIZE := 32.0
const RECALCULATE_ERROR := -1

var _parts: Node2D
var _parts_cache: Dictionary[ShipData, Node2D] = {}
var _error_cache: Dictionary[ShipData, int] = {}

var size: Vector2i:
	set = set_size
var ship: ShipData:
	set = set_ship

func set_size(new_size: Vector2i) -> void:
	size = new_size
	region_rect.size = TILE_SIZE * size

func is_cached(which_ship := ship) -> bool:
	return which_ship in _parts_cache

func cache() -> bool:
	return ship != null and _parts != null and _add_parts_to_cache()

func uncache(which_ship := ship) -> bool:
	return _parts_cache.erase(which_ship) and (which_ship == ship or _destroy_parts_in_cache(which_ship) )

func clear_cache() -> void:
	_parts_cache.keys().all(uncache)

func _add_parts_to_cache() -> bool:
	_parts_cache[ship] = _parts
	return true # <- Allows for some nice short-circuit syntax

func _destroy_parts_in_cache(which_ship: ShipData) -> bool:
	_parts_cache[which_ship].queue_free()
	return true # <- Allows for some nice short-circuit syntax

func set_ship(new_ship: ShipData) -> void:
	if ship == new_ship:
		return
	if ship != null:
		_clear_ship()
	ship = new_ship
	if ship != null:
		_load_ship()
	else:
		size = Vector2i.ZERO
	ship_changed.emit(self)

func _clear_ship() -> void:
	if ship in _parts_cache:
		Main.toggle_node(_parts, false)
	else:
		_parts.queue_free()
		_error_cache.erase(ship)
	ship.resized.disconnect(set_size)
	_parts = null

func _load_ship() -> void:
	if ship in _parts_cache:
		_parts = _parts_cache[ship]
		Main.toggle_node(_parts, true)
	else:
		sync()
	ship.resized.connect(set_size)
	size = ship.grid_size

func add_part(part: Node) -> void:
	if ship == null or not part is PartHitbox:
		return part.queue_free()
	part.reparent(_parts)
	_update_error(RECALCULATE_ERROR)

func _update_error(error: int) -> void:
	var is_saved := error == ShipData.PartError.OK
	_error_cache[ship] = error
	save_changed.emit(ship, is_saved)

func save(lazy := true) -> int:
	var error_flags := _error_cache[ship]
	if lazy and error_flags != RECALCULATE_ERROR:
		return error_flags
	ship.clear()
	error_flags = ShipData.PartError.OK
	# NOTE: This will break if you tamper with internal nodes
	for node in _parts.get_children():
		error_flags |= _save_part(node)
	_update_error(error_flags)
	return error_flags

func _save_part(part: PartHitbox) -> ShipData.PartError:
	var error := ship.add_part(part.data, part.get_top_left_corner(), part.placement)
	part.overlapping = error == ShipData.PartError.OVERLAP
	return error

func sync() -> void:
	if ship == null:
		return
	var parts := Node2D.new()
	add_child(parts, false, INTERNAL_MODE_BACK)
	#         ^^^^^ DO NOT MESS WITH THESE NODES!
	if _parts != null:
		_parts.queue_free()
	if ship in _parts_cache:
		_parts_cache[ship] = parts
	_parts = parts
	ship.for_each_part(_load_part)
	_update_error(ShipData.PartError.OK)

func _load_part(ship_part: ShipDataPart) -> void:
	var part := PartHitbox.create()
	part.data = ship_part.get_data()
	_parts.add_child(part)
	part.placement = ship_part.get_placement()
	part.position = TILE_SIZE * ship_part.get_center()
