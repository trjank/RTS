class_name PartManager extends RefCounted

enum LoadError {
	OK,
	FILE_NOT_FOUND,
	INCORRECT_FORMAT,
	INVALID_PART,
	INVALID_PART_PROPERTIES
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
	"z_index": TYPE_INT,
	"image_path": TYPE_STRING
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

func create_part(code: String, subtype = "") -> PartData:
	if code.length() != PartData.CODE_LENGTH or has_code(code) or not subtype in PartData.subtypes:
		return null
	var part := PartData.create_subtype(subtype)
	var atlas_id := _parts.size()
	part.code = code
	_code_to_id[code] = atlas_id
	_parts.push_back(part)
	return part

func load_part(code: String, properties: Dictionary) -> LoadError:
	var subtype = properties.get("subtype", "")
	var part := create_part(code, subtype)
	if part == null:
		return LoadError.INVALID_PART
	if not Util.type_check(properties, VALID_PART_PROPERTIES, true, Util.CAST_NUMERICS):
		return LoadError.INVALID_PART_PROPERTIES
	for property in properties:
		part[property] = properties[property]
	return LoadError.OK

func load_dictionary(data: Dictionary) -> LoadError:
	if not data.values().all(is_dictionary):
		return LoadError.INCORRECT_FORMAT
	var error := LoadError.OK
	for code in data:
		var part_error := load_part(code, data[code] )
		error = part_error if error == LoadError.OK else error
	return error

func load_json(file_path: String) -> LoadError:
	var text := FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(text)
	if FileAccess.get_open_error() != OK:
		return LoadError.FILE_NOT_FOUND
	if not data is Dictionary:
		return LoadError.INCORRECT_FORMAT
	return load_dictionary(data)

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

# NOTE: This may be very slow (drawing with CPU)
func draw_parts_on_atlas() -> void:
	for atlas_id in _parts.size():
		var part := _parts[atlas_id]
		var rect := Rect2i(Vector2i.ZERO, 32 * part.get_size() )
		atlas.blit_rect(part.image, rect, atlas_offsets[atlas_id] )
		part.atlas_rect = Rect2(atlas_offsets[atlas_id], part_sizes[atlas_id])
