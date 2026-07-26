@tool
class_name Star extends Planet

const STAR_SHADER := preload("res://map/star/star_plasma.tres")
const BLACK_HOLE_SHADER := preload("res://map/star/black_hole.tres")
const TEMPERATURE_PRIMARY_COLOR_GRADIENT := preload("res://map/star/temperature_primary_color_gradient.tres")
const TEMPERATURE_SECONDARY_COLOR_GRADIENT := preload("res://map/star/temperature_secondary_color_gradient.tres")

const INSTABILITY := 0.01 * GRAVITATIONAL_CONSTANT
const MIN_ENERGY := 0.0
const MAX_ENERGY := 5.0
const MIN_TEMPERATURE := 0.0
const MAX_TEMPERATURE := 1.0

@export_range(MIN_ENERGY, MAX_ENERGY, 0.01) var energy := MIN_ENERGY:
	set = set_energy
@export_range(MIN_TEMPERATURE, MAX_TEMPERATURE, 0.01) var temperature := MIN_TEMPERATURE:
	set = set_temperature

func _ready() -> void:
	super()
	#
	var min_energy := float(_map.preset.get("min_energy", MIN_ENERGY) )
	var max_energy := float(_map.preset.get("max_energy", MAX_ENERGY) )
	var min_temperature := float(_map.preset.get("min_temperature", MIN_TEMPERATURE) )
	var max_temperature := float(_map.preset.get("max_temperature", MAX_TEMPERATURE) )
	energy = _rng.randf_range(min_energy, max_energy)
	temperature = _rng.randf_range(min_temperature, max_temperature)

func set_mass(new_mass: float) -> void:
	super(new_mass)
	#
	update_shader()

func set_radius(new_radius: float) -> void:
	super(new_radius)
	#
	update_shader()

func is_black_hole() -> bool:
	var schwarzschild_radius := INSTABILITY * mass
	return radius <= schwarzschild_radius

func set_energy(new_energy: float) -> void:
	energy = clampf(new_energy, MIN_ENERGY, MAX_ENERGY)
	mesh_instance.set_instance_shader_parameter("emission_energy", energy)

func set_temperature(new_temperature: float) -> void:
	temperature = clampf(new_temperature, MIN_TEMPERATURE, MAX_TEMPERATURE)
	#
	var primary_color := TEMPERATURE_PRIMARY_COLOR_GRADIENT.sample(temperature)
	var secondary_color := TEMPERATURE_SECONDARY_COLOR_GRADIENT.sample(temperature)
	mesh_instance.set_instance_shader_parameter("emission_color_primary", primary_color)
	mesh_instance.set_instance_shader_parameter("emission_color_secondary", secondary_color)
	mesh_instance.set_instance_shader_parameter("accretion_disk_light_color", primary_color)

func update_shader() -> void:
	mesh_instance.material_override = BLACK_HOLE_SHADER if is_black_hole() else STAR_SHADER
