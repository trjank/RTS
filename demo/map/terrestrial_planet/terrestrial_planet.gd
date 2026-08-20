@tool
class_name TerrestrialPlanet extends Planet

const MIN_TEMPERATURE := 0.0
const MAX_TEMPERATURE := 1.0
const MIN_HUMIDITY := 0.0
const MAX_HUMIDITY := 1.0

@export_tool_button("Randomize") var button := generate_shader

@export_range(0.0, 1.0, 0.01) var temperature := 0.0:
	set = set_temperature
@export_range(0.0, 1.0, 0.01) var humidity := 0.0:
	set = set_humidity
@export var biome: Biome
@export var atmosphere: MeshInstance3D

func set_temperature(new_temperature: float) -> void:
	temperature = clampf(new_temperature, MIN_TEMPERATURE, MAX_TEMPERATURE)
	biome = Biome.from_climate(temperature, humidity)

func set_humidity(new_humidity: float) -> void:
	humidity = clampf(new_humidity, MIN_HUMIDITY, MAX_HUMIDITY)
	biome = Biome.from_climate(temperature, humidity)

func generate_from_map() -> void:
	super()
	#
	temperature = generate_randf_range("min_temperature", "max_temperature", MIN_TEMPERATURE, MAX_TEMPERATURE)
	humidity = generate_randf_range("min_humidity", "max_humidity", MIN_HUMIDITY, MAX_HUMIDITY)
	generate_shader()

func generate_shader() -> void:
	if biome == null:
		return push_warning("(TerrestrialPlanet) No biome found!")
	atmosphere.set_instance_shader_parameter("density", biome.atmosphere_density_curve.sample(rng.randf() ) )
	atmosphere.set_instance_shader_parameter("color", biome.atmosphere_color_gradient.sample(rng.randf() ) )
	mesh_instance.set_instance_shader_parameter("biome_color", biome.biome_color_gradient.sample(rng.randf() ) )
	mesh_instance.set_instance_shader_parameter("flat_color", biome.flat_color_gradient.sample(rng.randf() ) )
	mesh_instance.set_instance_shader_parameter("steep_color", biome.steep_color_gradient.sample(rng.randf() ) )
	mesh_instance.set_instance_shader_parameter("shore_color", biome.shore_color_gradient.sample(rng.randf() ) )
	mesh_instance.set_instance_shader_parameter("water_color", biome.water_color_gradient.sample(rng.randf() ) )
