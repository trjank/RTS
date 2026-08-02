class_name Map extends Resource

enum GenerationError {
	OK = 0,
	INVALID_SUBTYPE = 1 << 0,
	INVALID_PRESET = 1 << 1,
	DEPTH_LIMIT_REACHED = 1 << 2
}

# NOTE: You do not have to use all of these properties
const PRESET_SYNTAX: Dictionary[String, Variant.Type] = {
	"min_mass": TYPE_FLOAT,
	"max_mass": TYPE_FLOAT,
	"min_count": TYPE_INT,
	"max_count": TYPE_INT,
	"min_rotation": TYPE_FLOAT,
	"max_rotation": TYPE_FLOAT,
# For Orbiter below
	"min_orbit_radius": TYPE_FLOAT,
	"max_orbit_radius": TYPE_FLOAT,
	"min_orbit_offset": TYPE_FLOAT,
	"max_orbit_offset": TYPE_FLOAT,
# For Planet below
	"min_radius": TYPE_FLOAT,
	"max_radius": TYPE_FLOAT,
	"display_name": TYPE_STRING,
	"capturable": TYPE_BOOL,
	"min_tilt": TYPE_FLOAT,
	"max_tilt": TYPE_FLOAT,
	"capture_zone_radius_ratio": TYPE_FLOAT,
# For TerrestrialPlanet below
	"min_temperature": TYPE_FLOAT,
	"max_temperature": TYPE_FLOAT,
	"min_humidity": TYPE_FLOAT,
	"max_humidity": TYPE_FLOAT,
# For Star below
	"min_energy": TYPE_FLOAT,
	"max_energy": TYPE_FLOAT
}

var subtype: String
var preset := {}
var submaps: Array[Map] = []

static func from_dict(dict: Dictionary) -> Map:
	return from_unnested_dict(dict) if "root" in dict else from_nested_dict(dict)

static func from_nested_dict(dict: Dictionary) -> Map:
	var map := Map.new(dict.get("subtype", ""), dict)
	map.submaps.assign(dict.get("submaps", [] ).map(from_nested_dict) )
	return map

static func from_unnested_dict(dict: Dictionary) -> Map:
	var is_dict := func(value: Variant) -> bool: return value is Dictionary
	#
	if not "root" in dict or not dict.values().all(is_dict):
		return null
	var maps: Dictionary[String, Map] = {}
	var get_map := func(id: String) -> Map: return maps.get(id, null)
	for id in dict:
		maps[id] = Map.new(dict[id].get("subtype", ""), dict[id] )
	for id in dict:
		maps[id].submaps.assign(dict[id].submaps.map(get_map) )
	return maps["root"]

static func from_json(path: String) -> Map:
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.parse_string(text) as Dictionary
	return from_dict(json) if json != null else null

func _init(init_subtype := "", init_preset := {} ) -> void:
	subtype = init_subtype
	preset = init_preset

func is_preset_valid() -> bool:
	return TypeChecker.type_check(preset, PRESET_SYNTAX, false, TypeChecker.CAST_NUMBERS)

func to_dict() -> Dictionary:
	# Default to unnested to reduce duplication
	return to_unnested_dict()

func to_nested_dict() -> Dictionary:
	var submap_to_dict := func(submap: Map) -> Dictionary: return submap.to_nested_dict()
	#
	return {"subtype": subtype, "submaps": submaps.map(submap_to_dict) }.merged(preset)

func _add_to_unnested_dict(dict: Dictionary, counts: Dictionary[String, int] = {} ) -> String:
	var count: int = counts.get(subtype, 1)
	var id := "%s %d" % [subtype, count] if not counts.is_empty() else "root"
	var to_id := func(submap: Map) -> String: return submap._add_to_unnested_dict(dict, counts)
	counts[subtype] = count + 1
	dict[id] = {"subtype": subtype, "submaps": submaps.map(to_id) }.merged(preset)
	return id

func to_unnested_dict() -> Dictionary:
	var dict := {}
	_add_to_unnested_dict(dict)
	return dict

func save_json(path: String, nested := false) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	var dict := to_nested_dict() if nested else to_unnested_dict()
	file.store_string(JSON.stringify(dict, "\t") )
	file.close()
	return true

func _generate_one(index: int, count: int, parent: Node3D, battle_state: BattleState, rng: RandomNumberGenerator, node_storage: Array[Scenery], depth_limit := 1, shared_variables := {}, layer_variables := {} ) -> int:
	var scenery := Scenery.create(subtype)
	scenery.rng = rng
	scenery.battle_state = battle_state
	scenery.map = self
	scenery.index = index
	scenery.count = count
	parent.add_child(scenery)
	var error: int = GenerationError.OK
	#
	for submap in submaps:
		error |= submap.generate(scenery, battle_state, rng, node_storage, depth_limit - 1, shared_variables)
	scenery.use_layer_variables(layer_variables)
	scenery.use_shared_variables(shared_variables)
	node_storage.push_back(scenery)
	return error

func generate(parent: Node3D, battle_state: BattleState, rng: RandomNumberGenerator, node_storage: Array[Scenery], depth_limit := 1, shared_variables := {} ) -> int:
	assert(parent != null)
	assert(rng != null)
	#
	if depth_limit <= 0:
		return GenerationError.DEPTH_LIMIT_REACHED
	if not subtype in Scenery.subtypes:
		return GenerationError.INVALID_SUBTYPE
	if not is_preset_valid():
		return GenerationError.INVALID_PRESET
	var min_count := int(preset.get("min_count", 1) )
	var max_count := int(preset.get("max_count", min_count) )
	var count := rng.randi_range(min_count, max_count)
	var layer_variables := {}
	var error: int = GenerationError.OK
	#
	for i in count:
		error |= _generate_one(i, count, parent, battle_state, rng, node_storage, depth_limit, shared_variables, layer_variables)
	return error
