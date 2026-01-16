class_name ShipData extends RefCounted

signal image_changed(new_image: Image)

enum PartError {
	OK = 0,
	IS_NULL = 1 << 0,
	OUT_OF_BOUNDS = 1 << 1,
	OVERLAP = 1 << 2,
	INCORRECT_SIZE_BYTES = 1 << 3
}
enum BoundaryFlags {
	NONE = 0,
	RIGHT = 1 << 0,
	TOP = 1 << 1,
	LEFT = 1 << 2,
	BOTTOM = 1 << 3,
	FULL = RIGHT | TOP | LEFT | BOTTOM
}

const USE_MIPMAPS := false
const MAX_NAME_LENGTH := 100
const DEFAULT_NAME := "Unnamed"
const NULL_PART_ID := 0
const BYTES_U8 := 1
const BYTES_U16 := 2
const BYTES_UTF32_CHAR := 4
const BYTES_UTF32_CODE := PartData.CODE_LENGTH * BYTES_UTF32_CHAR
const BYTES_PER_PART := BYTES_U16 + BYTES_U16 + BYTES_U8 + BYTES_UTF32_CODE

var name := DEFAULT_NAME:
	set = set_name
var cost := 0
var mass := 0.0
var warp_per_sec := 0.0
var shield_per_sec := 0.0
var energy_per_sec := 0.0
var max_hp := 0.0
var max_warp := 0.0
var max_shield := 0.0
var max_energy := 0.0
var thrust := 0.0
var turn_impulse := 0.0
var part_counts: Dictionary[PartData, int]
var center: Vector2
var image: Image

var _grid_bounds: Rect2i
var _ship_bounds := Rect2i(0, 0, 1, 1)
var _part_ids: Int32Grid
var _parts: Array[ShipDataPart] = [null]
var _part_clusters := DisjointSets.new()
var _bytes := StreamPeerBuffer.new()

func _init(width: int, height: int) -> void:
	assert(width > 0 and height > 0)
	_grid_bounds = Rect2i(0, 0, width, height)
	_part_ids = Int32Grid.new(width, height)
	_part_ids.fill(NULL_PART_ID)
	_part_clusters.create_set()

func set_name(new_name: String) -> void:
	name = new_name.substr(0, MAX_NAME_LENGTH)

func is_named() -> bool:
	return name != DEFAULT_NAME

func is_empty() -> bool:
	return _parts.size() <= 1

func count_parts() -> int:
	return _parts.size() - 1

func count_part_clusters() -> int:
	return _part_clusters.count_sets() - 1

func are_parts_connected() -> bool:
	return _part_clusters.count_sets() <= 2

func has_part_id(part_id: int) -> bool:
	return 0 <= part_id and part_id < _parts.size()

func get_part(part_id: int) -> ShipDataPart:
	return _parts[part_id]

func get_part_at(xy: Vector2i) -> ShipDataPart:
	return _parts[_part_ids.get_int(xy.x, xy.y) if _ship_bounds.has_point(xy) else NULL_PART_ID]

func get_grid_rect() -> Rect2i:
	return _grid_bounds

func get_ship_rect() -> Rect2i:
	return _ship_bounds

func get_center() -> Vector2:
	return Rect2(_ship_bounds).get_center()

func clear() -> void:
	reset_stats()
	_bytes.clear()
	_parts = [null]
	_part_ids.fill(NULL_PART_ID)
	_part_clusters.resize(1)

func reset_stats() -> void:
	cost           = 0
	thrust         = 0.0
	mass           = 0.0
	turn_impulse   = 0.0
	max_warp       = 0.0
	max_shield     = 0.0
	max_energy     = 0.0
	warp_per_sec   = 0.0
	shield_per_sec = 0.0
	energy_per_sec = 0.0

func add_part_stats(part_data: PartData, count := 1) -> void:
	thrust         += count * part_data.thrust
	cost           += count * part_data.cost
	mass           += count * part_data.mass
	turn_impulse   += count * part_data.turn_impulse
	max_warp       += count * part_data.warp
	max_shield     += count * part_data.shield
	max_energy     += count * part_data.energy
	warp_per_sec   += count * part_data.warp_per_sec
	shield_per_sec += count * part_data.shield_per_sec
	energy_per_sec += count * part_data.energy_per_sec

func add_to_part_count(part_data: PartData, count := 1) -> void:
	part_counts[part_data] = part_counts.get(part_data, 0) + count

func calculate_stats() -> void:
	reset_stats()
	for part in part_counts:
		add_part_stats(part, part_counts[part] )

func for_each_part(f: Callable) -> void:
	for part_id in range(1, _parts.size() ):
		f.call(_parts[part_id] )

func _connect_neighbor_to_part(neighbor: ShipDataPart, part_id: int) -> void:
	if neighbor != null:
		_part_clusters.union_sets(neighbor.get_id(), part_id)

func _for_vertical_edge(x: int, y_start: int, y_end: int, f: Callable) -> void:
	for y in range(y_start, y_end):
		f.call(get_part_at(Vector2i(x, y) ) )

func _for_horizontal_edge(y: int, x_start: int, x_end: int, f: Callable) -> void:
	for x in range(x_start, x_end):
		f.call(get_part_at(Vector2i(x, y) ) )

func for_each_neighbor(part_id: int, boundary_flags: int, f: Callable) -> void:
	var rect := _parts[part_id].get_rect()
	if boundary_flags & BoundaryFlags.LEFT:
		_for_vertical_edge(rect.position.x - 1, rect.position.y, rect.end.y, f)
	if boundary_flags & BoundaryFlags.RIGHT:
		_for_vertical_edge(rect.end.x, rect.position.y, rect.end.y, f)
	if boundary_flags & BoundaryFlags.TOP:
		_for_horizontal_edge(rect.position.y - 1, rect.position.x, rect.end.x, f)
	if boundary_flags & BoundaryFlags.BOTTOM:
		_for_horizontal_edge(rect.end.y, rect.position.x, rect.end.x, f)

func add_part(part_data: PartData, top_left_corner: Vector2i, placement := PartImage.Placement.ROT_0) -> PartError:
	if part_data == null:
		return PartError.IS_NULL
	var boundary := part_data.get_boundary(placement)
	var size := part_data.get_size(placement)
	var rect := Rect2i(top_left_corner, size)
	# NOTE: Only parts with no boundary can be placed on top of other parts
	if not _grid_bounds.encloses(rect):
		return PartError.OUT_OF_BOUNDS
	if boundary != BoundaryFlags.NONE and not _part_ids.rect_equals(rect, NULL_PART_ID):
		return PartError.OVERLAP
	# NOTE: DisjointSets gives us a near O(1) way to update connectedness
	var part_id := _part_clusters.create_set()
	var part := ShipDataPart.new(part_id, part_data, rect, placement, boundary)
	_ship_bounds = rect if is_empty() else _ship_bounds.merge(rect)
	_parts.push_back(part)
	_serialize_part(part_id)
	add_to_part_count(part_data)
	# NOTE: We keep all connected parts in the same set using DisjointSets
	# It is very fast to add parts to sets, but much harder to remove them
	# This is one of the reasons there is no remove_part method
	if boundary == BoundaryFlags.NONE:
		_part_clusters.union_sets(part_id, NULL_PART_ID)
	else:
		_part_ids.fill_rect(rect, part_id)
		for_each_neighbor(part_id, boundary, _connect_neighbor_to_part.bind(part_id) )
	return PartError.OK

func serialize() -> PackedByteArray:
	assert(_bytes.get_size() % BYTES_PER_PART != 0)
	return _bytes.data_array

func deserialize(from_bytes: PackedByteArray, part_manager: PartManager) -> int:
	assert(part_manager != null)
	if from_bytes.size() % BYTES_PER_PART != 0:
		return PartError.INCORRECT_SIZE_BYTES
	clear()
	_bytes.data_array = from_bytes
	var error: int = PartError.OK
	while _bytes.get_available_bytes() > 0:
		error |= _deserialize_part(part_manager)
	return error

func _serialize_part(part_id: int) -> void:
	var part := _parts[part_id]
	_bytes.put_u16(part.get_rect().position.x)
	_bytes.put_u16(part.get_rect().position.y)
	_bytes.put_u8(part.get_placement() )
	_bytes.put_data(part.get_data().get_code().to_utf32_buffer() )

func _deserialize_part(part_manager: PartManager) -> PartError:
	var top_left_corner := Vector2i(_bytes.get_u16(), _bytes.get_u16() )
	var placement := _bytes.get_u8() as PartImage.Placement
	var i := _bytes.get_position()
	var code := _bytes.data_array.slice(i, i + BYTES_UTF32_CODE).get_string_from_utf32()
	var part := part_manager.get_part_from_code(code)
	_bytes.seek(i + BYTES_UTF32_CODE)
	return add_part(part, top_left_corner, placement)

func generate_image() -> void:
	var size := PartImage.TILE_SIZE * _ship_bounds.size
	var offset := PartImage.TILE_SIZE * _ship_bounds.position
	image = Image.create_empty(size.x, size.y, USE_MIPMAPS, PartImage.FORMAT)
	for_each_part(_draw_part.bind(offset) )
	image_changed.emit(image)

func _draw_part(part: ShipDataPart, offset: Vector2i) -> void:
	if part.get_boundary() == BoundaryFlags.NONE:
		return
	var part_image := part.get_image()
	var from := Rect2i(Vector2i.ZERO, part_image.get_size() )
	var to := PartImage.TILE_SIZE * part.get_rect().position
	# NOTE: This uses the CPU, but is very fast due to c++ memcpy
	image.blit_rect(part_image, from, to - offset)
