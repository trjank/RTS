class_name Grid extends MeshInstance3D

signal ship_changed(grid: Grid)
signal save_changed(some_ship: ShipData, saved: bool)

# NOTE: Changing this order breaks ALL current and stored ships!
enum PartPlacement {
	ROT_0,
	ROT_90,
	ROT_180,
	ROT_270,
	FLIP_ROT_0,
	FLIP_ROT_90,
	FLIP_ROT_180,
	FLIP_ROT_270,
	NUM_PLACEMENTS
}

const ROTATION_INCREMENT = PI / 2
const MIN_GRID_SIZE := Vector2i.ONE
const MAX_CACHE_SIZE := 30
const RECALCULATE_ERROR := -1
# Standardized measurements (PLEASE USE THESE!)
const METERS_PER_TILE := 0.32
const TILES_PER_METER := 3.125
const PX_PER_TILE := 32
const TILES_PER_PX := 0.03125
const METERS_PER_PX := 0.01
const PX_PER_METER := 100.0

@export var grid_center_marker: MeshInstance3D
@export var part_selection: PartSelection

var _parts: Node3D
var _parts_cache: Dictionary[ShipData, Node3D] = {}
var _error_cache: Dictionary[ShipData, int] = {}

var size: Vector2i:
	set = set_size
var ship: ShipData:
	set = set_ship

static func is_placement_flipped(placement: PartPlacement) -> bool:
	return PartPlacement.FLIP_ROT_0 <= placement

static func placement_to_rotation(placement: PartPlacement) -> Vector3:
	return Vector3(0.0, (placement % 4) * ROTATION_INCREMENT, 0.0)

static func to_placement(flipped: bool, rotation_3d: Vector3) -> PartPlacement:
	# Maps 315º-45º -> 0,
	# 45º-135º -> 1,
	# 135º-225º -> 2,
	# 225º-315º -> 3
	var rot := posmod(round(rotation_3d.y / ROTATION_INCREMENT), 4)
	return (4 + rot if flipped else rot) as PartPlacement

static func is_placement_valid(placement: PartPlacement) -> bool:
	return 0 <= placement and placement < PartPlacement.NUM_PLACEMENTS

func _ready() -> void:
	size = MIN_GRID_SIZE

func set_size(new_size: Vector2i) -> void:
	size = new_size.max(MIN_GRID_SIZE)
	mesh.size = METERS_PER_TILE * size
	mesh.center_offset.x = 0.5 * mesh.size.x
	mesh.center_offset.z = 0.5 * mesh.size.y
	grid_center_marker.position = mesh.center_offset
	set_instance_shader_parameter("num_tiles", Vector2(size) )

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
	var parts := Node3D.new()
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
	var position_2d := Grid.METERS_PER_TILE * ship_part.get_center()
	part.data = ship_part.get_data()
	_parts.add_child(part)
	part.placement = ship_part.get_placement()
	part.position.x = position_2d.x
	part.position.z = position_2d.y
	part.selected.connect(part_selection.select_part_and_drag.bind(part) )
