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
	"cost_data": TYPE_DICTIONARY,
	"warp": TYPE_FLOAT,
	"shield": TYPE_FLOAT,
	"energy": TYPE_FLOAT,
	"warp_per_sec": TYPE_FLOAT,
	"shield_per_sec": TYPE_FLOAT,
	"energy_per_sec": TYPE_FLOAT,
	"thrust": TYPE_FLOAT,
	"torque": TYPE_FLOAT,
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
	"lifetime_sec": TYPE_FLOAT,
	"damage": TYPE_FLOAT,
	"energy_drain": TYPE_FLOAT,
	"shield_penetration": TYPE_FLOAT,
	"can_mine": TYPE_BOOL,
	"mining_rate_data": TYPE_DICTIONARY,
# For BulletData below
	"launch_velocity": TYPE_FLOAT,
	"linear_damp": TYPE_FLOAT,
	"sound_variation": TYPE_FLOAT,
	"trail_enabled": TYPE_BOOL,
	"trail_inner_color": TYPE_COLOR,
	"trail_outer_color": TYPE_COLOR,
	"trail_glow": TYPE_FLOAT,
	"trail_roundness": TYPE_FLOAT,
	"trail_flicker_strength": TYPE_FLOAT,
	"trail_width": TYPE_FLOAT,
	"trail_force": TYPE_FLOAT,
# For LaserData below
	"color": TYPE_COLOR,
	"glow": TYPE_FLOAT,
	"chain_range": TYPE_FLOAT,
	"max_chains": TYPE_INT,
	"chain_multiplier": TYPE_FLOAT,
	"display_width": TYPE_FLOAT,
# For DeathRayData below
	"thickness": TYPE_FLOAT,
	"max_range": TYPE_FLOAT,
	"inner_beam_color": TYPE_COLOR,
	"outer_beam_color": TYPE_COLOR,
	"inner_beam_size": TYPE_FLOAT,
	"volatility": TYPE_FLOAT,
	"hit_damage_multiplier": TYPE_FLOAT,
	"hit_energy_drain_multiplier": TYPE_FLOAT,
	"max_hits": TYPE_INT,
# For FlamethrowerData below
	"speed": TYPE_FLOAT,
	"fade_speed": TYPE_FLOAT,
	"start_color": TYPE_COLOR,
	"end_color": TYPE_COLOR
}

var _parts: Dictionary[String, PartData] = {}

static func is_dictionary(variant: Variant) -> bool:
	return variant is Dictionary

func clear() -> void:
	_parts.clear()

func count_parts() -> int:
	return _parts.size()

func has_part(code: String) -> bool:
	return code in _parts

func get_part(code: String) -> PartData:
	return _parts.get(code)

func for_each_part(f: Callable) -> void:
	for part in _parts:
		f.call(_parts[part] )

func create_part(code: String, image_path: String, width: int, height: int, subtype = "") -> PartData:
	if code.length() != PartData.CODE_LENGTH or has_part(code) or not subtype in PartData.subtypes:
		return null
	var part := PartData.create_subtype(subtype, code, image_path, width, height)
	_parts[code] = part
	part._manager = self
	part_created.emit(part)
	return part

func load_part(code: String, properties: Dictionary) -> LoadError:
	# These are all constant parameters, so we cannot use set
	var subtype = properties.get("subtype", "")
	var width: int = properties.get("width", PartData.MIN_SIZE)
	var height: int = properties.get("height", PartData.MIN_SIZE)
	var image_path: String = properties.get("image_path", "")
	#
	if not TypeChecker.type_check(properties, VALID_PART_PROPERTIES, true, TypeChecker.CAST_NUMBERS_AND_COLORS):
		return LoadError.INVALID_PART_PROPERTIES
	var part := create_part(code, image_path, width, height, subtype)
	if part == null:
		return LoadError.INVALID_PART
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
