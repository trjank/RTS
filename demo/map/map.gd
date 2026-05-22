class_name Map extends RefCounted

# NOTE: You do not have to use all of these properties
const PRESET_SYNTAX: Dictionary[String, Variant.Type] = {
	"min_mass": TYPE_FLOAT,
	"max_mass": TYPE_FLOAT,
	"min_orbit_radius": TYPE_FLOAT,
	"max_orbit_radius": TYPE_FLOAT,
	"min_orbit_offset": TYPE_FLOAT,
	"max_orbit_offset": TYPE_FLOAT,
	"capturable": TYPE_BOOL,
	"min_radius": TYPE_FLOAT,
	"max_radius": TYPE_FLOAT,
	"textures": TYPE_ARRAY,
	"display_name": TYPE_STRING
}

var subtype: String
var preset := {}
var submaps: Array[Map] = []

func _init(init_subtype: String) -> void:
	subtype = init_subtype

func is_preset_valid() -> bool:
	return Util.type_check(preset, PRESET_SYNTAX, false, Util.CAST_NUMERICS)

func generate(parent: Node3D, rng: RandomNumberGenerator, node_storage: Array[Scenery], depth_limit := 1) -> Scenery:
	assert(parent != null)
	assert(rng != null)
	#
	if depth_limit <= 0 or not subtype in Scenery.subtypes or not is_preset_valid():
		return null
	var scenery := Scenery.create(subtype)
	scenery._rng = rng
	scenery._map = self
	parent.add_child(scenery)
	for submap in submaps:
		submap.generate(scenery, rng, node_storage, depth_limit - 1)
	node_storage.push_back(scenery)
	return scenery
