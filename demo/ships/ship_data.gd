class_name ShipData extends RefCounted

signal cleared
signal save_changed(is_saved: bool)
signal renamed(new_name: String)
signal resized(new_grid_size: Vector2i)
signal generated_image(new_image: Image, new_texture: ImageTexture)
signal generated_thumbnail(new_thumbnail: Image, new_thumbnail_texture: ImageTexture)
signal stats_updated
signal finalized

enum PartError {
	OK = 0,
	IS_NULL = 1 << 0,
	OUT_OF_BOUNDS = 1 << 1,
	OVERLAP = 1 << 2,
	INCORRECT_SIZE_BYTES = 1 << 3
}
enum PlacementError {
	OK = 0,
	WEAPON_HAS_NO_MOUNT = 1 << 0,
	USELESS_MODIFIER = 1 << 1
}

static var PROPERTIES: Dictionary[String, Variant.Type] = {
	"name": TYPE_STRING,
	"priority": TYPE_INT,
	"grid_width": TYPE_INT,
	"grid_height": TYPE_INT,
	"unit_logic_uid": TYPE_INT,
	"thumbnail_bytes": TYPE_PACKED_BYTE_ARRAY,
	"part_bytes": TYPE_PACKED_BYTE_ARRAY,
	"extra_bytes": TYPE_PACKED_BYTE_ARRAY
}
static var DB_PROPERTIES: Dictionary[String, Variant.Type] = {
	"id": TYPE_INT
}

const PRINT_ERRORS := true
const THUMBNAIL_SIZE := 256
const NULL_PART_ID := 0
const MAX_NAME_LENGTH := 100
const USE_MIPMAPS := false
const MIN_GRID_SIZE := Vector2i.ONE
const MAX_GRID_SIZE := Vector2i(256, 256)
const BYTES_PER_PART_CODE := PartData.CODE_LENGTH * Bytes.CHAR_UTF32
const BYTES_PER_PART := Bytes.U16 + Bytes.U16 + Bytes.U8 + BYTES_PER_PART_CODE

var priority := 0
var name := "":
	set = set_name
var grid_width: int:
	get = get_grid_width, set = set_grid_width
var grid_height: int:
	get = get_grid_width, set = set_grid_height
var grid_size: Vector2i:
	get = get_grid_size, set = set_grid_size
var cost := StrategicResources.new()
var mass := 0.0
var warp_per_sec := 0.0
var shield_per_sec := 0.0
var energy_per_sec := 0.0
var max_hp := 0.0
var max_warp := 0.0
var max_shield := 0.0
var max_energy := 0.0
var thrust := 0.0
var torque := 0.0
var part_counts: Dictionary[PartData, int]
var center: Vector2
var node_parts: Array[ShipDataPart] = []
var id := 0
var db: ShipManager:
	get = get_db, set = set_db
var image: Image:
	set = set_image
var thumbnail: Image:
	set = set_thumbnail
var saved := true:
	set = set_saved
var is_finalized := false
var unit_logic := UnitLogic.DEFAULT:
	set = set_unit_logic
var unit_logic_uid: int:
	get = get_unit_logic_uid, set = set_unit_logic_uid
var thumbnail_bytes:
	get = get_thumbnail_bytes, set = set_thumbnail_bytes
var part_bytes: PackedByteArray:
	get = serialize, set = deserialize
## This is intended to future-proof databases (can add and remove features without changing database structure)
var extra_bytes := PackedByteArray():
	set = deserialize_extra_bytes

var _db: WeakRef = weakref(null)
var _saved := true
var _texture: ImageTexture
var _thumbnail_texture: ImageTexture
var _grid_bounds := Rect2i(Vector2i.ZERO, MIN_GRID_SIZE)
var _ship_bounds := Rect2i()
var _part_ids := PackedInt32Grid.new(MIN_GRID_SIZE)
var _parts: Array[ShipDataPart] = [null]
var _part_clusters := DisjointSets.new()
var _part_bytes := StreamPeerBuffer.new()
var _placement_error: int = PlacementError.OK
var _material := ShaderMaterial.new()

static func _static_init() -> void:
	DB_PROPERTIES.merge(PROPERTIES)

static func from_dict(dict: Dictionary, use_id := false, default: ShipData = null) -> ShipData:
	var ship_data := ShipData.new()
	return ship_data if ship_data.load_dict(dict, use_id) else default

static func from_uid(uid: int) -> ShipData:
	var static_db := ShipManager.from_id(uid & ShipManager.MAX_ID)
	return static_db.get_unit_logic(uid >> ShipManager.ID_BITS) if static_db != null else null

func _init() -> void:
	_material.shader = preload("res://ships/ship.gdshader")
	_material.set_shader_parameter("shield_texture", preload("res://ships/shield_texture.tres") )

func to_dict(use_id := false) -> Dictionary:
	return TypeChecker.to_dict(self, DB_PROPERTIES if use_id else PROPERTIES)

func load_dict(dict: Dictionary, use_id := false) -> bool:
	return TypeChecker.load_dict(self, dict, DB_PROPERTIES if use_id else PROPERTIES, TypeChecker.CAST_NUMBERS)

func get_db() -> ShipManager:
	return _db.get_ref()

func get_uid() -> int:
	return (db.get_id() if db != null else 0) | (id << ShipManager.ID_BITS)

func is_saved() -> bool:
	return _saved

func sync(lazy := true) -> bool:
	saved = (saved and lazy) or (db != null and db.sync_ship(self) )
	return saved

func save(lazy := true) -> bool:
	saved = (saved and lazy) or (db != null and db.save_ship(self) )
	return saved

func is_empty() -> bool:
	return _parts.size() <= 1

func get_texture() -> ImageTexture:
	return _texture

func get_thumbnail_texture() -> ImageTexture:
	return _thumbnail_texture

func get_thumbnail_bytes() -> PackedByteArray:
	return PackedByteArray() if thumbnail == null or thumbnail.is_empty() else thumbnail.save_webp_to_buffer()

func get_placement_error_flags() -> int:
	return _placement_error

func get_grid_rect() -> Rect2i:
	return _grid_bounds

func get_ship_rect() -> Rect2i:
	return _ship_bounds

func get_center() -> Vector2:
	return Rect2(_ship_bounds).get_center()

func get_grid_size() -> Vector2i:
	return _grid_bounds.size

func get_material() -> ShaderMaterial:
	return _material

func count_parts() -> int:
	return _parts.size() - 1

func count_part_clusters() -> int:
	return _part_clusters.count_sets() - 1

func are_parts_connected() -> bool:
	return _part_clusters.count_sets() <= 2

func part_id_atv(point: Vector2i) -> int:
	return _part_ids.get_intv(point) if _ship_bounds.has_point(point) else NULL_PART_ID

func part_id_at(x: int, y: int) -> int:
	return part_id_atv(Vector2i(x, y) )

func part_atv(point: Vector2i) -> ShipDataPart:
	return _parts[part_id_atv(point) ]

func part_at(x: int, y: int) -> ShipDataPart:
	return _parts[part_id_at(x, y) ]

## Returns null for invalid ids or NULL_PART_ID
func get_part(part_id: int) -> ShipDataPart:
	return _parts[part_id if 0 <= part_id and part_id < _parts.size() else NULL_PART_ID]

func get_part_data(part_id: int) -> PartData:
	var part := get_part(part_id)
	return part.get_data() if part != null else null

func get_unit_logic_uid() -> int:
	return unit_logic.get_uid()

## This creates a copy (if you can, use get_part instead)
func get_parts() -> Array[ShipDataPart]:
	var copy := _parts.duplicate()
	copy.remove_at(NULL_PART_ID)
	return copy

func get_grid_width() -> int:
	return _grid_bounds.size.x

func get_grid_height() -> int:
	return _grid_bounds.size.y

func set_grid_width(new_grid_width: int) -> bool:
	return set_grid_size(Vector2i(new_grid_width, grid_height) )

func set_grid_height(new_grid_height: int) -> bool:
	return set_grid_size(Vector2i(grid_width, new_grid_height) )

func set_db(new_db: ShipManager) -> void:
	_db = weakref(new_db)

func set_unit_logic(new_unit_logic: UnitLogic) -> void:
	unit_logic = new_unit_logic if new_unit_logic != null else UnitLogic.DEFAULT

func set_unit_logic_uid(new_unit_logic_uid: int) -> void:
	unit_logic = UnitLogic.from_uid(new_unit_logic_uid)

func set_thumbnail(new_thumbnail: Image) -> void:
	thumbnail = new_thumbnail
	_thumbnail_texture = ImageTexture.create_from_image(thumbnail) if thumbnail != null else null
	generated_thumbnail.emit()

func set_thumbnail_bytes(new_thumbnail_bytes: PackedByteArray) -> Error:
	var new_thumbnail = Image.new()
	var error := new_thumbnail.load_webp_from_buffer(new_thumbnail_bytes)
	thumbnail = new_thumbnail
	return error

func set_saved(new_saved: bool) -> void:
	if new_saved == saved:
		return
	saved = new_saved
	save_changed.emit(saved)

## For one-line set and save do: var success := set_name(..) and save()
func set_name(new_name: String) -> bool:
	new_name = new_name.left(MAX_NAME_LENGTH)
	if name == new_name:
		return false
	name = new_name
	renamed.emit(name)
	return true

## For one-line set and save do: var success := set_grid_size(..) and save()
func set_grid_size(new_grid_size: Vector2i) -> bool:
	new_grid_size = new_grid_size.clamp(MIN_GRID_SIZE, MAX_GRID_SIZE)
	if _grid_bounds.size == new_grid_size:
		return false
	_grid_bounds.size = new_grid_size
	_part_ids.size = new_grid_size
	clear()
	resized.emit(new_grid_size)
	return true

func set_image(new_image: Image) -> void:
	image = new_image
	_texture = ImageTexture.create_from_image(image) if image != null else null
	_material.set_shader_parameter("ship_texture", _texture)
	_material.set_shader_parameter("size", _ship_bounds.size * Measurement.METERS_PER_PX)

func clear() -> void:
	image = null
	_parts = [null]
	_part_ids.fill(NULL_PART_ID)
	_part_clusters.resize(1)
	_part_clusters.reset()
	_ship_bounds = Rect2i()
	_part_bytes.clear()
	_reset_stats()
	node_parts.clear()
	part_counts.clear()
	cleared.emit()

func _reset_stats() -> void:
	thrust         = 0.0
	mass           = 0.0
	torque         = 0.0
	max_hp         = 0.0
	max_warp       = 0.0
	max_shield     = 0.0
	max_energy     = 0.0
	warp_per_sec   = 0.0
	shield_per_sec = 0.0
	energy_per_sec = 0.0
	cost.reset()

func add_part_stats(part_data: PartData, count := 1) -> void:
	thrust         += count * part_data.thrust
	mass           += count * part_data.mass
	torque         += count * part_data.torque
	max_hp         += count * part_data.hp
	max_warp       += count * part_data.warp
	max_shield     += count * part_data.shield
	max_energy     += count * part_data.energy
	warp_per_sec   += count * part_data.warp_per_sec
	shield_per_sec += count * part_data.shield_per_sec
	energy_per_sec += count * part_data.energy_per_sec
	cost.add(part_data.cost, count)

func add_to_part_count(part_data: PartData, count := 1) -> void:
	part_counts[part_data] = part_counts.get(part_data, 0) + count

func calculate_stats() -> void:
	_reset_stats()
	#
	for part in part_counts:
		add_part_stats(part, part_counts[part] )
	stats_updated.emit()

func finalize(forceful := false) -> int:
	if is_finalized and not forceful:
		return _placement_error
	for i in range(1, _parts.size() ):
		_placement_error |= _parts[i].on_ship_data_pre_finalize(self)
	for i in range(1, _parts.size() ):
		_placement_error |= _parts[i].on_ship_data_post_finalize(self)
	is_finalized = true
	finalized.emit()
	return _placement_error

func raycast_v(x: int, y_from: int, y_to: int, add_to := PackedInt32Array() ) -> PackedInt32Array:
	for y in range(y_from, y_to):
		add_to.append(part_id_at(x, y) )
	return add_to

func raycast_h(x_from: int, x_to: int, y: int, add_to := PackedInt32Array() ) -> PackedInt32Array:
	for x in range(x_from, x_to):
		add_to.append(part_id_at(x, y) )
	return add_to

func _add_edge_h_neighbors(boundary_flags: int, rect: Rect2i, add_to: PackedInt32Array) -> void:
	if boundary_flags & Boundary.TOP_EDGE:
		raycast_h(rect.position.x, rect.end.x, rect.position.y - 1, add_to)
	if boundary_flags & Boundary.BOTTOM_EDGE:
		raycast_h(rect.position.x, rect.end.x, rect.end.y, add_to)

func _add_edge_v_neighbors(boundary_flags: int, rect: Rect2i, add_to: PackedInt32Array) -> void:
	if boundary_flags & Boundary.LEFT_EDGE:
		raycast_v(rect.position.x - 1, rect.position.y, rect.end.y, add_to)
	if boundary_flags & Boundary.RIGHT_EDGE:
		raycast_v(rect.end.x, rect.position.y, rect.end.y, add_to)

func _add_corner_neighbors(boundary_flags: int, rect: Rect2i, add_to: PackedInt32Array) -> void:
	if boundary_flags & Boundary.TOP_LEFT_CORNER:
		add_to.append(part_id_at(rect.position.x - 1, rect.position.y - 1) )
	if boundary_flags & Boundary.TOP_RIGHT_CORNER:
		add_to.append(part_id_at(rect.end.x, rect.position.y - 1) )
	if boundary_flags & Boundary.BOTTOM_LEFT_CORNER:
		add_to.append(part_id_at(rect.position.x - 1, rect.end.y) )
	if boundary_flags & Boundary.BOTTOM_RIGHT_CORNER:
		add_to.append(part_id_at(rect.end.x, rect.end.y) )

func get_neighbors(part_id: int, boundary_flags: int) -> PackedInt32Array:
	var neighbors := PackedInt32Array()
	var rect := _parts[part_id].get_rect()
	_add_corner_neighbors(boundary_flags, rect, neighbors)
	_add_edge_h_neighbors(boundary_flags, rect, neighbors)
	_add_edge_v_neighbors(boundary_flags, rect, neighbors)
	return neighbors

## NOTE: Parts with no boundary can be placed on top of other parts
func add_part(part_data: PartData, top_left_corner: Vector2i, rotation := Rotation.Discrete.ROT_0, serialize_part := true) -> PartError:
	if part_data == null:
		return PartError.IS_NULL
	var boundary := part_data.get_rotated_boundary(rotation)
	var size := part_data.get_rotated_size(rotation)
	var rect := Rect2i(top_left_corner, size)
	if not _grid_bounds.encloses(rect):
		return PartError.OUT_OF_BOUNDS
	if boundary != Boundary.NONE and not _part_ids.is_rect_empty(rect, NULL_PART_ID):
		return PartError.OVERLAP
	_create_part(part_data, rect, rotation, boundary, serialize_part)
	is_finalized = false
	saved = false
	return PartError.OK

func _create_part(part_data: PartData, rect: Rect2i, rotation: Rotation.Discrete, boundary: int, serialize_part: bool) -> void:
	var part_id := _part_clusters.create_set()
	var part := part_data.create_ship_data_part(part_id, rect, rotation, boundary)
	_parts.push_back(part)
	if part_data.becomes_node_on_ship():
		node_parts.push_back(part)
	if serialize_part:
		_serialize_part(part_id)
	add_to_part_count(part_data)
	_connect_part_to_grid(part_id, boundary, rect)

## NOTE: This cannot be undone except with clear()
func connect_parts(part_id: int, neighbor_id: int) -> void:
	if neighbor_id != NULL_PART_ID:
		_part_clusters.union_sets(neighbor_id, part_id)

func _connect_part_to_grid(part_id: int, boundary: int, rect: Rect2i) -> void:
	_ship_bounds = rect if _ship_bounds.size == Vector2i.ZERO else _ship_bounds.merge(rect)
	if boundary == Boundary.NONE:
		return _part_clusters.union_sets(part_id, NULL_PART_ID)
	for neighbor_id in get_neighbors(part_id, boundary):
		connect_parts(part_id, neighbor_id)
	_part_ids.fill_rect(rect, part_id)

func serialize_extra_bytes() -> void:
	pass # TODO: Add additional features here

func deserialize_extra_bytes(_extra_bytes: PackedByteArray) -> void:
	pass # TODO: Add additional features here

func serialize() -> PackedByteArray:
	assert(_part_bytes.get_size() % BYTES_PER_PART == 0)
	#
	return _part_bytes.data_array

func deserialize(from_bytes: PackedByteArray) -> int:
	if from_bytes.size() % BYTES_PER_PART != 0:
		return PartError.INCORRECT_SIZE_BYTES
	clear()
	var error: int = PartError.OK
	_part_bytes.data_array = from_bytes
	#
	while _part_bytes.get_available_bytes() > 0:
		error |= _deserialize_part()
	if PRINT_ERRORS and error != PartError.OK:
		push_error("ShipData#%d failed to deserialize parts: " % id + Globals.format_enum(error, PartError) )
	calculate_stats()
	return error

func _serialize_part(part_id: int) -> void:
	var part := _parts[part_id]
	_part_bytes.put_u16(part.get_rect().position.x)
	_part_bytes.put_u16(part.get_rect().position.y)
	_part_bytes.put_u8(part.get_rotation() )
	_part_bytes.put_data(part.get_data().get_code().to_utf32_buffer() )

func _deserialize_part() -> PartError:
	var top_left_corner := Vector2i(_part_bytes.get_u16(), _part_bytes.get_u16() )
	var placement := _part_bytes.get_u8() as Rotation.Discrete
	var code := (_part_bytes.get_partial_data(BYTES_PER_PART_CODE)[1] as PackedByteArray).get_string_from_utf32()
	var part := PartManager.get_part(code)
	return add_part(part, top_left_corner, placement, false)

func generate_thumbnail() -> void:
	if image == null:
		return push_error("(ShipData) No thumbnail to generate for #%d" % id)
	thumbnail = image.duplicate()
	thumbnail.resize(THUMBNAIL_SIZE, THUMBNAIL_SIZE)
	_thumbnail_texture = ImageTexture.create_from_image(thumbnail)
	generated_thumbnail.emit()

func generate_image() -> void:
	var size := Measurement.PX_PER_TILE * _ship_bounds.size
	var offset := Measurement.PX_PER_TILE * _ship_bounds.position
	var new_image := ImageAsset.blank_image(size, USE_MIPMAPS)
	# NOTE: Part draw order does not matter because they are guaranteed to not overlap
	for i in range(1, _parts.size() ):
		_draw_part(new_image, _parts[i], offset)
	image = new_image
	generated_image.emit(image, _texture)

func _draw_part(to_image: Image, part: ShipDataPart, offset: Vector2i) -> void:
	if part.get_boundary() == Boundary.NONE or not part.get_data().is_image_valid():
		return
	# NOTE: Using the GPU to assemble parts in this case is slower (just use the CPU)
	var part_image := part.get_image()
	var from := Rect2i(Vector2i.ZERO, part_image.get_size() )
	var to := Measurement.PX_PER_TILE * part.get_rect().position
	to_image.blit_rect(part_image, from, to - offset)
