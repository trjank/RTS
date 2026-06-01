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
# For Orbiter below
	"min_orbit_radius": TYPE_FLOAT,
	"max_orbit_radius": TYPE_FLOAT,
	"min_orbit_offset": TYPE_FLOAT,
	"max_orbit_offset": TYPE_FLOAT,
	"min_radius": TYPE_FLOAT,
	"max_radius": TYPE_FLOAT,
	"display_name": TYPE_STRING,
# For Planet below
	"capturable": TYPE_BOOL
}

var subtype: String
var preset := {}
var submaps: Array[Map] = []

static func _to_dict(map: Map) -> Dictionary:
	return map.to_dict()

static func from_dict(dict: Dictionary) -> Map:
	var map := Map.new(dict.get("subtype", "") )
	map.submaps.assign(dict.get("submaps", [] ).map(from_dict) )
	map.preset = dict
	return map

func _init(init_subtype := "") -> void:
	subtype = init_subtype

func is_preset_valid() -> bool:
	return TypeChecker.type_check(preset, PRESET_SYNTAX, false, TypeChecker.CAST_NUMBERS)

func to_dict() -> Dictionary:
	var dict := {
		"subtype": subtype,
		"submaps": submaps.map(_to_dict)
	}
	dict.merge(preset)
	return dict

func load_dict(dict: Dictionary) -> void:
	subtype = dict.get("subtype", "")
	submaps.assign(dict.get("submaps", [] ).map(from_dict) )
	preset = dict

func load_json(path: String) -> bool:
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.parse_string(text) as Dictionary
	if json == null:
		return false
	load_dict(json)
	return true

func save_json(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	var json := JSON.stringify(to_dict() )
	file.store_string(json)
	file.close()
	return true

func _generate_one(index: int, count: int, parent: Node3D, battle_state: BattleState, rng: RandomNumberGenerator, node_storage: Array[Scenery], depth_limit := 1) -> int:
	var scenery := Scenery.create(subtype)
	scenery._rng = rng
	scenery._battle_state = battle_state
	scenery._map = self
	scenery.generation_index = index
	scenery.generation_count = count
	parent.add_child(scenery)
	var error: int = GenerationError.OK
	#
	for submap in submaps:
		error |= submap.generate(scenery, battle_state, rng, node_storage, depth_limit - 1)
	node_storage.push_back(scenery)
	return error

func generate(parent: Node3D, battle_state: BattleState, rng: RandomNumberGenerator, node_storage: Array[Scenery], depth_limit := 1) -> int:
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
	var error: int = GenerationError.OK
	#
	for i in count:
		error |= _generate_one(i, count, parent, battle_state, rng, node_storage, depth_limit)
	return error
