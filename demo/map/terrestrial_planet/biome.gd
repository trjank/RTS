@tool
class_name Biome extends Resource

static var biomes: Array[Biome] = load("res://map/terrestrial_planet/biomes/biomes_list.tres").biomes

@export var atmosphere_density_curve: Curve
@export var atmosphere_color_gradient: Gradient
@export var biome_color_gradient: Gradient
@export var flat_color_gradient: Gradient
@export var steep_color_gradient: Gradient
@export var shore_color_gradient: Gradient
@export var water_color_gradient: Gradient
@export var temperature_humidity := Vector2.ZERO

static func closer_biome(biome1: Biome, biome2: Biome, to: Vector2) -> Biome:
	return biome1 if biome1.temperature_humidity.distance_squared_to(to) < biome2.temperature_humidity.distance_squared_to(to) else biome2

static func from_climate(temperature: float, humidity: float) -> Biome:
	var point := Vector2(temperature, humidity)
	var best_biome := null if biomes.is_empty() else biomes[0]
	#
	for biome in biomes:
		best_biome = closer_biome(best_biome, biome, point)
	return best_biome
