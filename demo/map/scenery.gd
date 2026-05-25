class_name Scenery extends Node3D

const GRAVITATIONAL_CONSTANT := 10.0
const MIN_MASS := 0.0
const MIN_ORBIT_RADIUS := 0.1
const DRAW_THICKNESS := 1.0
const DRAW_COLOR := Color.WHITE
const DRAW_RESOLUTION := 100
const BIG_NUMBER_NOT_INF := 1.0e10

# NOTE: Do NOT use preload (this variable is static)
static var subtypes: Dictionary[String, PackedScene] = {
	"Star": load("res://map/star/star.tscn"),
	"TerrestrialPlanet": load("res://map/terrestrial_planet/terrestrial_planet.tscn"),
	"JovianPlanet": load("res://map/jovian_planet/jovian_planet.tscn"),
	"Asteroid": load("res://map/asteroid/asteroid.tscn")
}

static func create(subtype: String) -> Scenery:
	assert(subtype in subtypes)
	#
	return subtypes[subtype].instantiate() as Scenery

var mass := MIN_MASS:
	set = set_mass
var time := 0.0:
	set = set_time
var orbit_angle := 0.0:
	set = set_orbit_angle
var orbit_offset := 0.0:
	set = set_orbit_offset
var orbit_radius := MIN_ORBIT_RADIUS:
	set = set_orbit_radius

var _map: Map
var _rng: RandomNumberGenerator

func get_orbit_center() -> Scenery:
	return get_parent() as Scenery

func get_orbit_mass() -> float:
	var center := get_orbit_center()
	return center.mass if center != null else MIN_MASS

func get_speed() -> float:
	return GRAVITATIONAL_CONSTANT * get_orbit_mass() / orbit_radius

func get_angular_speed() -> float:
	return 0.0
	#return get_speed() / orbit_radius

func set_mass(new_mass: float) -> void:
	mass = maxf(new_mass, MIN_MASS)

func set_time(new_time: float) -> void:
	time = new_time
	orbit_angle = orbit_offset + time * get_angular_speed()

func set_orbit_angle(new_orbit_angle: float) -> void:
	orbit_angle = fposmod(new_orbit_angle, TAU)
	update_position()

func set_orbit_radius(new_orbit_radius: float) -> void:
	orbit_radius = maxf(new_orbit_radius, MIN_ORBIT_RADIUS)
	update_position()

func set_orbit_offset(new_orbit_offset: float) -> void:
	orbit_offset = fposmod(new_orbit_offset, TAU)
	update_position()

func update_position() -> void:
	rotation.y = orbit_angle
	var position_2d := orbit_radius * Vector2.from_angle(orbit_angle)
	position = Vector3(position_2d.x, 0.0, position_2d.y)

func _ready() -> void:
	var min_mass := float(_map.preset.get("min_mass", 0.0) )
	var max_mass := float(_map.preset.get("max_mass", BIG_NUMBER_NOT_INF) )
	var min_orbit_radius := float(_map.preset.get("min_orbit_radius", 0.0) )
	var max_orbit_radius := float(_map.preset.get("max_orbit_radius", 0.0) )
	var min_orbit_offset := float(_map.preset.get("min_orbit_offset", 0.0) )
	var max_orbit_offset := float(_map.preset.get("max_orbit_offset", TAU) )
	# NOTE: INF causes undefined behavior for randf_range
	mass = _rng.randf_range(min_mass, max_mass)
	orbit_radius = _rng.randf_range(min_orbit_radius, max_orbit_radius)
	orbit_offset = _rng.randf_range(min_orbit_offset, max_orbit_offset)

func _process(delta: float) -> void:
	time += delta
