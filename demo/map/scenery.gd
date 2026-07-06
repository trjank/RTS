class_name Scenery extends Node3D

const MIN_MASS := 0.0
const MAX_MASS := 1.0e10

# NOTE: Do NOT use preload (this variable is static)
static var subtypes: Dictionary[String, PackedScene] = {
	"Star": load("res://map/star/star.tscn"),
	"TerrestrialPlanet": load("res://map/terrestrial_planet/terrestrial_planet.tscn"),
	"JovianPlanet": load("res://map/jovian_planet/jovian_planet.tscn"),
	"Asteroid": load("res://map/asteroid/asteroid.tscn"),
	"Moon": load("res://map/moon/moon.tscn")
}

static func create(subtype: String) -> Scenery:
	assert(subtype in subtypes)
	#
	return subtypes[subtype].instantiate() as Scenery

var generation_index := 0
var generation_count := 1
var hp := INF
var mass := MIN_MASS:
	set = set_mass
var time := 0.0:
	set = set_time
var resources := StrategicResources.new()

var _target := SceneryTarget.new()
var _map: Map
var _rng: RandomNumberGenerator
var _battle_state: BattleState

func get_target() -> SceneryTarget:
	return _target

func set_mass(new_mass: float) -> void:
	mass = maxf(new_mass, MIN_MASS)

func kill() -> void:
	queue_free()

func hit(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		kill()

## Override this to add additional functionality
func set_time(new_time: float) -> void:
	time = new_time

## Override this to pass data between Scenery objects during generation
func use_shared_variables(_shared_variables := {} ) -> void:
	_shared_variables["scenery_count"] = _shared_variables.get("scenery_count", 0) + 1

func _ready() -> void:
	_target._scenery = self
	# NOTE: INF causes undefined behavior for randf_range
	var min_mass := float(_map.preset.get("min_mass", MIN_MASS) )
	var max_mass := float(_map.preset.get("max_mass", MAX_MASS) )
	var min_rotation := float(_map.preset.get("min_rotation", 0.0) )
	var max_rotation := float(_map.preset.get("min_rotation", min_rotation) )
	mass = _rng.randf_range(min_mass, max_mass)
	rotation.y = _rng.randf_range(min_rotation, max_rotation)

func _exit_tree() -> void:
	_target._scenery = null

func _physics_process(dt: float) -> void:
	_target.global_position = global_position
	time = _battle_state.time if _battle_state != null else time + dt
