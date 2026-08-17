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
	"y": TYPE_FLOAT,
	"image_path": TYPE_STRING,
	"boundary": TYPE_INT,
# For ThrusterData below
	"trail_length_speed_ratio": TYPE_FLOAT,
	"trail_width_ratio": TYPE_FLOAT,
	"trail_data": TYPE_DICTIONARY,
# For WeaponData below
	"projectile_code": TYPE_STRING,
	"barrel_z": TYPE_FLOAT,
	"center_z": TYPE_FLOAT,
# For WeaponModifierData below
	"modifier_data": TYPE_DICTIONARY,
	"modshare_efficiency": TYPE_FLOAT,
	"modifier_boundary": TYPE_INT,
# For WeaponMountData below
	"modifier_efficiency": TYPE_FLOAT,
	"arc_degrees": TYPE_FLOAT,
# For ProjectileData below
	"lifetime_sec": TYPE_FLOAT,
	"damage": TYPE_FLOAT,
	"energy_drain": TYPE_FLOAT,
	"shield_penetration": TYPE_FLOAT,
	"effective_range": TYPE_FLOAT,
	"can_mine": TYPE_BOOL,
	"mining_rate_data": TYPE_DICTIONARY,
# For BulletData below
	"launch_velocity": TYPE_FLOAT,
	"linear_damp": TYPE_FLOAT,
	"sound_variation": TYPE_FLOAT,
	"trail_enabled": TYPE_BOOL,
	"trail_length": TYPE_FLOAT,
# For LaserData below
	"max_chains": TYPE_INT,
	"glow": TYPE_FLOAT,
	"drift_speed": TYPE_FLOAT,
	"inner_color": TYPE_COLOR,
	"outer_color": TYPE_COLOR,
	"multihit_modifier_data": TYPE_DICTIONARY,
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
	"particulates": TYPE_FLOAT,
	"pitch_scale": TYPE_FLOAT,
	"start_color": TYPE_COLOR,
	"end_color": TYPE_COLOR,
# For WingData below
	"z": TYPE_FLOAT,
	"wing_min_tilt": TYPE_FLOAT,
	"wing_max_tilt": TYPE_FLOAT
}

var _parts: Dictionary[String, PartData] = {}

func clear() -> void:
	_parts.clear()

func count_parts() -> int:
	return _parts.size()

func has_part(code: String) -> bool:
	return code in _parts

func get_part(code: String) -> PartData:
	return _parts.get(code)

## This creates a copy (if you can, use get_part instead)
func get_parts() -> Array[PartData]:
	var copy := [] as Array[PartData]
	copy.assign(_parts.values() )
	return copy

func create_part(code: String, size := PartData.DEFAULT_SIZE, subtype = "", boundary := Boundary.ALL_EDGES) -> PartData:
	if code.length() != PartData.CODE_LENGTH or has_part(code) or not subtype in PartData.subtypes:
		return null
	var part := PartData.create_subtype(subtype, code, size, boundary)
	_parts[code] = part
	part._manager = self
	part_created.emit(part)
	return part

func load_part(code: String, properties: Dictionary) -> LoadError:
	# These are all constant parameters, so we cannot use set
	var subtype = properties.get("subtype", "")
	var width: int = properties.get("width", PartData.MIN_SIZE)
	var height: int = properties.get("height", PartData.MIN_SIZE)
	#
	if not TypeChecker.type_check(properties, VALID_PART_PROPERTIES, true, TypeChecker.CAST_NUMBERS_AND_COLORS):
		return LoadError.INVALID_PART_PROPERTIES
	var part := create_part(code, Vector2i(width, height), subtype)
	if part == null:
		return LoadError.INVALID_PART
	for property in properties:
		part.set(property, properties[property] )
	return LoadError.OK

func load_dict(data: Dictionary) -> int:
	var is_dict := func(value: Variant) -> bool: return value is Dictionary
	#
	if not data.values().all(is_dict):
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
	return load_dict(data)
