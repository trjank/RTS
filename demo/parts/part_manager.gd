class_name PartManager extends RefCounted

signal part_created(part_data: PartData)

enum LoadError {
	OK = 0,
	FILE_NOT_FOUND = 1 << 0,
	INCORRECT_FORMAT = 1 << 1,
	INVALID_PART = 1 << 2,
	INVALID_PART_PROPERTIES = 1 << 3
}

# NOTE: You do not have to use all of these properties
const VALID_PART_PROPERTIES: Dictionary[String, Variant.Type] = {
	"name": TYPE_STRING,
	"tab": TYPE_STRING,
	"description": TYPE_STRING,
	"code": TYPE_STRING,
	"subtype": TYPE_STRING,
	"connected": TYPE_BOOL,
	"cost": TYPE_INT,
	"warp": TYPE_FLOAT,
	"shield": TYPE_FLOAT,
	"energy": TYPE_FLOAT,
	"warp_per_sec": TYPE_FLOAT,
	"shield_per_sec": TYPE_FLOAT,
	"energy_per_sec": TYPE_FLOAT,
	"thrust": TYPE_FLOAT,
	"turn_impulse": TYPE_FLOAT,
	"hp": TYPE_FLOAT,
	"mass": TYPE_FLOAT,
	"size": TYPE_VECTOR2I,
	"width": TYPE_INT,
	"height": TYPE_INT,
	"y_level": TYPE_FLOAT,
	"image_path": TYPE_STRING,
# For WeaponData below
	"projectile_code": TYPE_STRING,
# For WeaponModifierData below
	"flat_range": TYPE_FLOAT,
	"flat_energy": TYPE_FLOAT,
	"flat_speed": TYPE_FLOAT,
	"flat_cooldown": TYPE_FLOAT,
	"multiplier_range": TYPE_FLOAT,
	"multiplier_energy": TYPE_FLOAT,
	"multiplier_speed": TYPE_FLOAT,
	"multiplier_cooldown": TYPE_FLOAT,
# For ProjectileData below
	"damage": TYPE_FLOAT,
	"energy_drain": TYPE_FLOAT,
	"shield_penetration": TYPE_FLOAT,
# For BulletData below
	"launch_velocity": TYPE_FLOAT,
	"linear_damp": TYPE_FLOAT,
# For LaserData below
	"color": TYPE_COLOR,
	"glow": TYPE_FLOAT,
	"lifetime_sec": TYPE_FLOAT,
	"max_chains": TYPE_INT,
	"chain_multiplier": TYPE_FLOAT,
	"display_width": TYPE_FLOAT
}

var part_sizes := PackedVector2Array()
var atlas_offsets := PackedVector2Array()
var atlas: Image

var _parts: Array[PartData] = []
var _code_to_id: Dictionary[String, int] = {}

static func is_dictionary(variant: Variant) -> bool:
	return variant is Dictionary

func clear() -> void:
	_code_to_id.clear()
	_parts.clear()
	part_sizes.clear()
	atlas_offsets.clear()
	atlas = null

func count_parts() -> int:
	return _parts.size()

func has_id(atlas_id: int) -> bool:
	return 0 <= atlas_id and atlas_id < _parts.size()

func has_code(part_code: String) -> bool:
	return part_code in _code_to_id

func get_part_from_id(atlas_id: int) -> PartData:
	return _parts[atlas_id]

func get_part_from_code(code: String) -> PartData:
	return _parts[_code_to_id[code] ]

func create_part(code: String, image_path: String, width: int, height: int, subtype = "") -> PartData:
	if code.length() != PartData.CODE_LENGTH or has_code(code) or not subtype in PartData.subtypes:
		return null
	var part := PartData.create_subtype(subtype, code, image_path, width, height)
	var atlas_id := _parts.size()
	_code_to_id[code] = atlas_id
	_parts.push_back(part)
	part._manager = self
	part_created.emit(part)
	return part

func load_part(code: String, properties: Dictionary) -> LoadError:
	var subtype = properties.get("subtype", "")
	var width: int = properties.get("width", PartData.MIN_SIZE)
	var height: int = properties.get("height", PartData.MIN_SIZE)
	#   ^^^^^^ These are all constant parameters, so we cannot use set
	var image_path: String = properties.get("image_path", "")
	var part := create_part(code, image_path, width, height, subtype)
	if part == null:
		return LoadError.INVALID_PART
	if not Util.type_check(properties, VALID_PART_PROPERTIES, true, Util.CAST_NUMERICS):
		return LoadError.INVALID_PART_PROPERTIES
	for property in properties:
		part.set(property, properties[property] )
	return LoadError.OK

func load_dictionary(data: Dictionary) -> int:
	if not data.values().all(is_dictionary):
		return LoadError.INCORRECT_FORMAT
	var error: int = LoadError.OK
	for code in data:
		error |= load_part(code, data[code] )
	return error

func load_json(file_path: String) -> int:
	var text := FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(text)
	if FileAccess.get_open_error() != OK:
		return LoadError.FILE_NOT_FOUND
	if not data is Dictionary:
		return LoadError.INCORRECT_FORMAT
	return load_dictionary(data)

func for_each_part(f: Callable) -> void:
	for part in _parts:
		f.call(part)

func generate_atlas() -> void:
	update_atlas_part_sizes()
	var atlas_data := Geometry2D.make_atlas(part_sizes)
	atlas_offsets = atlas_data.points
	atlas = Image.create(atlas_data.size.x, atlas_data.size.y, false, Image.FORMAT_RGBA8)
	draw_parts_on_atlas()

func update_atlas_part_sizes() -> void:
	part_sizes.resize(_parts.size() )
	for atlas_id in _parts.size():
		part_sizes[atlas_id] = Vector2(32 * _parts[atlas_id].get_size() )

func draw_parts_on_atlas() -> void:
	for atlas_id in _parts.size():
		var part := _parts[atlas_id]
		var rect := Rect2i(Vector2i.ZERO, 32 * part.get_size() )
		atlas.blit_rect(part.image, rect, atlas_offsets[atlas_id] )
		part.atlas_rect = Rect2(atlas_offsets[atlas_id], part_sizes[atlas_id])
