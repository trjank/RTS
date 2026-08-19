@tool
class_name Scenery extends Node3D

const MIN_MASS := 0.0
const MAX_MASS := 1.0e10
const ROMAN_NUMERAL_TABLE: PackedStringArray = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

# NOTE: Do NOT use preload (this variable is static)
static var subtypes: Dictionary[String, PackedScene] = {
	"Star": load("res://map/star/star.tscn"),
	"TerrestrialPlanet": load("res://map/terrestrial_planet/terrestrial_planet.tscn"),
	"JovianPlanet": load("res://map/jovian_planet/jovian_planet.tscn"),
	"Asteroid": load("res://map/asteroid/asteroid.tscn"),
	"Moon": load("res://map/moon/moon.tscn"),
	"Spawnpoint": load("res://map/spawnpoint.tscn")
}
static var TEST_RNG := RandomNumberGenerator.new():
	set(__): push_error("(Scenery) TEST_RNG is immutable!")

static func create(subtype: String) -> Scenery:
	assert(subtype in subtypes)
	#
	return subtypes[subtype].instantiate() as Scenery

var index := 0:
	set = set_index
var count := 1:
	set = set_count
var hp := INF
var mass := MIN_MASS:
	set = set_mass
var rng := TEST_RNG:
	set = set_rng
var time := 0.0:
	set = set_time
var resources := StrategicResources.new()
var map: Map
var battle: Battle

var _target := SceneryTarget.new()

func _ready() -> void:
	if map != null:
		generate_from_map()
	_target._scenery = self

func get_target() -> SceneryTarget:
	return _target

func get_roman_numeral() -> String:
	return ROMAN_NUMERAL_TABLE[index] if index < ROMAN_NUMERAL_TABLE.size() else ""

func set_index(new_index: int) -> void:
	index = maxi(new_index, 0)

func set_count(new_count: int) -> void:
	count = maxi(new_count, 0)

func set_mass(new_mass: float) -> void:
	mass = maxf(new_mass, MIN_MASS)

func set_rng(new_rng: RandomNumberGenerator) -> void:
	rng = new_rng if new_rng != null else TEST_RNG

func set_time(new_time: float) -> void:
	time = new_time

func kill() -> void:
	queue_free()

func hit(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		kill()

## Used to pass data between Scenery and Battle during generation
func use_shared_variables(shared_variables := {} ) -> void:
	shared_variables["scenery_count"] = shared_variables.get("scenery_count", 0) + 1

## Used to pass data between Scenery objects during generation
func use_layer_variables(_layer_variables := {} ) -> void:
	pass # (override this method)

func generate_from_map() -> void:
	position.x = map.preset.get("x", position.x)
	position.y = map.preset.get("y", position.y)
	position.z = map.preset.get("z", position.z)
	mass = generate_randf_range("min_mass", "max_mass", MIN_MASS, MAX_MASS)
	rotation.y = generate_randf_radians("min_rotation", "max_rotation")

func generate_randf_radians(min_name: String, max_name: String) -> float:
	# Map uses degrees, but radians are more useful
	return deg_to_rad(generate_randf_range(min_name, max_name, 0.0, 360.0) )

## NOTE: INF causes undefined behavior for randf_range
func generate_randf_range(min_name: String, max_name: String, default_min := 0.0, default_max := 1.0) -> float:
	var min_value := float(map.preset.get(min_name, default_min) )
	var max_value := float(map.preset.get(max_name, default_max) )
	return rng.randf_range(min_value, max_value)

func _exit_tree() -> void:
	_target._scenery = null

func _physics_process(dt: float) -> void:
	time = battle.time if battle != null else time + dt
	_target.global_position = global_position
