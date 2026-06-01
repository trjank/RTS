class_name Star extends Planet

const INSTABILITY := GRAVITATIONAL_CONSTANT
const STAR_MATERIAL := preload("res://map/star/star_plasma.tres")
const BLACK_HOLE_SHADER := preload("res://shaders/black_hole.tres")

var energy: float:
	get = get_energy,
	set = set_energy

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

func get_primary_color() -> Color:
	return mesh_instance.get_instance_shader_parameter("emission_color_primary")

func get_secondary_color() -> Color:
	return mesh_instance.get_instance_shader_parameter("emissioN_color_secondary")

func get_energy() -> float:
	return mesh_instance.get_instance_shader_parameter("emission_energy")

func set_energy(new_energy: float) -> void:
	mesh_instance.set_instance_shader_parameter("emission_energy", new_energy)

func set_primary_color(new_primary_color: Color) -> void:
	mesh_instance.set_instance_shader_parameter("emission_color_primary", new_primary_color)

func set_secondary_color(new_secondary_color: float) -> void:
	mesh_instance.set_instance_shader_parameter("emission_color_secondary", new_secondary_color)

func update_shader() -> void:
	pass
	#sprite.material_overlay = BLACK_HOLE_SHADER if is_black_hole() else STAR_SHADER
