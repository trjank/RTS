@tool
class_name Biome extends RefCounted

static var DESERT := Biome.from_folder("res://map/terrestrial_planet/desert", Vector2(1.0, 0.3) ):
	set(__): push_error("(Biome) Biome.DESERT is immutable!")
static var TEMPERATE_FOREST := Biome.from_folder("res://map/terrestrial_planet/temperate_forest", Vector2(0.2, 0.5) ):
	set(__): push_error("(Biome) Biome.TEMPERATE_FOREST is immutable!")
static var TROPICAL_RAINFOREST := Biome.from_folder("res://map/terrestrial_planet/tropical_rainforest", Vector2(1.0, 1.0) ):
	set(__): push_error("(Biome) Biome.TROPICAL_RAINFOREST is immutable!")
static var TUNDRA := Biome.from_folder("res://map/terrestrial_planet/tundra", Vector2(0.0, 0.0) ):
	set(__): push_error("(Biome) Biome.TUNDRA is immutable!")
static var VOLCANO := Biome.from_folder("res://map/terrestrial_planet/volcano", Vector2(1.0, 0.0) ):
	set(__): push_error("(Biome) Biome.VOLCANO is immutable!")

static var biomes: Array[Biome] = [TEMPERATE_FOREST, DESERT, TUNDRA, TROPICAL_RAINFOREST, VOLCANO]

var biome_color_gradient: Gradient
var flat_color_gradient: Gradient
var steep_color_gradient: Gradient
var shore_color_gradient: Gradient
var water_color_gradient: Gradient
var temperature_humidity := Vector2.ZERO

static func closer_biome(biome1: Biome, biome2: Biome, to: Vector2) -> Biome:
	assert(biome1 != null)
	assert(biome2 != null)
	#
	return biome1 if biome1.temperature_humidity.distance_squared_to(to) < biome2.temperature_humidity.distance_squared_to(to) else biome2

static func to_biome(temperature: float, humidity: float) -> Biome:
	var point := Vector2(temperature, humidity)
	var best_biome := biomes[0]
	#
	for biome in biomes:
		best_biome = closer_biome(best_biome, biome, point)
	return best_biome

static func from_folder(folder_path: String, init_temperature_humidity := Vector2.ZERO) -> Biome:
	var biome := Biome.new()
	biome.temperature_humidity = init_temperature_humidity
	biome.biome_color_gradient = load(folder_path + "/temperature_biome_color_gradient.tres")
	biome.flat_color_gradient = load(folder_path + "/temperature_flat_color_gradient.tres")
	biome.steep_color_gradient = load(folder_path + "/temperature_steep_color_gradient.tres")
	biome.shore_color_gradient = load(folder_path + "/temperature_shore_color_gradient.tres")
	biome.water_color_gradient = load(folder_path + "/temperature_water_color_gradient.tres")
	return biome

func generate_biome_color(rng: RandomNumberGenerator) -> Color:
	return biome_color_gradient.sample(rng.randf() )

func generate_flat_color(rng: RandomNumberGenerator) -> Color:
	return flat_color_gradient.sample(rng.randf() )

func generate_steep_color(rng: RandomNumberGenerator) -> Color:
	return steep_color_gradient.sample(rng.randf() )

func generate_shore_color(rng: RandomNumberGenerator) -> Color:
	return shore_color_gradient.sample(rng.randf() )

func generate_water_color(rng: RandomNumberGenerator) -> Color:
	return water_color_gradient.sample(rng.randf() )
