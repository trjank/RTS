class_name Grid extends MeshInstance3D

# NOTE: If the ship does not save properly, try force_recalculate_error()

signal ship_changed(grid: Grid)
signal save_changed(some_ship: ShipData, saved: bool)

const MIN_GRID_SIZE := Vector2i.ONE
const MAX_CACHE_SIZE := 30
const RECALCULATE_ERROR := -1

@export var grid_center_marker: MeshInstance3D

var _parts: Node3D
var _parts_cache: Dictionary[ShipData, Node3D] = {}
var _error_cache: Dictionary[ShipData, int] = {}

var size: Vector2i:
	set = set_size
var ship: ShipData:
	set = set_ship

func _ready() -> void:
	size = MIN_GRID_SIZE

func set_size(new_size: Vector2i) -> void:
	size = new_size.max(MIN_GRID_SIZE)
	mesh.size = Measurement.METERS_PER_TILE * size
	mesh.center_offset.x = 0.5 * mesh.size.x
	mesh.center_offset.z = 0.5 * mesh.size.y
	grid_center_marker.position = mesh.center_offset
	set_instance_shader_parameter("num_tiles", Vector2(size) )

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

## Used in case that parts are modified or reparented outside this class
func force_recalculate_error() -> void:
	_update_error(RECALCULATE_ERROR)

func is_cached(which_ship := ship) -> bool:
	return which_ship in _parts_cache

func cache() -> void:
	if MAX_CACHE_SIZE <= _parts_cache.size():
		_parts_cache.erase(_parts_cache.keys()[0] )
	if ship != null and _parts != null:
		_parts_cache[ship] = _parts

func uncache(which_ship := ship) -> void:
	if not which_ship in _parts_cache:
		return
	_parts_cache[which_ship].queue_free()
	_parts_cache.erase(which_ship)

func clear_cache() -> void:
	_parts_cache.keys().all(uncache)

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

func save(lazy := true) -> int:
	if lazy and _error_cache[ship] != RECALCULATE_ERROR:
		return _error_cache[ship]
	ship.clear()
	var error_flags: int = ShipData.PartError.OK
	#
	for node in _parts.get_children():
		error_flags |= _save_part(node)
	_update_error(error_flags)
	return error_flags

func _save_part(part: PartHitbox) -> ShipData.PartError:
	var error := ship.add_part(part.data, part.get_top_left_corner(), part.discrete_rotation)
	part.overlapping = error == ShipData.PartError.OVERLAP
	return error

func sync(lazy := true) -> void:
	if ship == null or (lazy and _error_cache.get(ship, RECALCULATE_ERROR) != RECALCULATE_ERROR):
		return
	var parts := Node3D.new()
	add_child(parts, false, INTERNAL_MODE_BACK)
	if _parts != null:
		_parts.queue_free()
	if ship in _parts_cache:
		_parts_cache[ship] = parts
	_parts = parts
	#
	for part in ship.get_parts():
		_load_part(part)
	_update_error(ShipData.PartError.OK)

func _update_error(error: int) -> void:
	var is_saved := error == ShipData.PartError.OK
	_error_cache[ship] = error
	save_changed.emit(ship, is_saved)

func _load_part(ship_part: ShipDataPart) -> void:
	var part := PartHitbox.create()
	var position_2d := Measurement.METERS_PER_TILE * ship_part.get_center()
	part.data = ship_part.get_data()
	_parts.add_child(part)
	part.discrete_rotation = ship_part.get_rotation()
	part.position.x = position_2d.x
	part.position.z = position_2d.y
