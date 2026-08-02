@tool
class_name TerrestrialPlanet extends Planet

const MIN_TEMPERATURE := 0.0
const MAX_TEMPERATURE := 1.0
const MIN_HUMIDITY := 0.0
const MAX_HUMIDITY := 1.0

@export var atmosphere: MeshInstance3D
@export_range(0.0, 1.0, 0.01) var temperature := 0.0:
	set = set_temperature
@export_range(0.0, 1.0, 0.01) var humidity := 0.0:
	set = set_humidity
@export_tool_button("Generate Shader") var button := generate_shader

var _biome := Biome.TEMPERATE_FOREST

func get_biome() -> Biome:
	return _biome

func set_temperature(new_temperature: float) -> void:
	temperature = clampf(new_temperature, MIN_TEMPERATURE, MAX_TEMPERATURE)
	_generate_biome()

func set_humidity(new_humidity: float) -> void:
	humidity = clampf(new_humidity, MIN_HUMIDITY, MAX_HUMIDITY)
	_generate_biome()

func _generate_biome() -> void:
	_biome = Biome.to_biome(temperature, humidity)

func generate_from_map() -> void:
	super()
	#
	temperature = generate_randf_range("min_temperature", "max_temperature", MIN_TEMPERATURE, MAX_TEMPERATURE)
	humidity = generate_randf_range("min_humidity", "max_humidity", MIN_HUMIDITY, MAX_HUMIDITY)
	generate_shader()

func generate_shader() -> void:
	assert(rng != null)
	#
	atmosphere.set_instance_shader_parameter("density", _biome.generate_atmosphere_density(rng) )
	mesh_instance.set_instance_shader_parameter("biome_color", _biome.generate_biome_color(rng) )
	mesh_instance.set_instance_shader_parameter("flat_color", _biome.generate_flat_color(rng) )
	mesh_instance.set_instance_shader_parameter("steep_color", _biome.generate_steep_color(rng) )
	mesh_instance.set_instance_shader_parameter("shore_color", _biome.generate_shore_color(rng) )
	mesh_instance.set_instance_shader_parameter("water_color", _biome.generate_water_color(rng) )
