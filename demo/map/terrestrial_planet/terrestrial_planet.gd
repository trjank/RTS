class_name TerrestrialPlanet extends Planet

var flat_color: Color:
	get = get_flat_color,
	set = set_flat_color
var steep_color: Color:
	get = get_flat_color,
	set = set_flat_color
var shore_color: Color:
	get = get_shore_color,
	set = set_shore_color
var shore_height: float:
	get = get_shore_height,
	set = set_shore_height
# TODO: Water color

func get_flat_color() -> Color:
	return mesh_instance.get_instance_shader_parameter("flat_color")

func get_steep_color() -> Color:
	return mesh_instance.get_instance_shader_parameter("steep_color")

func get_shore_color() -> Color:
	return mesh_instance.get_instance_shader_parameter("shore_color")

func get_shore_height() -> float:
	return mesh_instance.get_instance_shader_parameter("shore_height")

func set_flat_color(new_flat_color: Color) -> void:
	mesh_instance.set_instance_shader_parameter("flat_color", new_flat_color)

func set_steep_color(new_steep_color: Color) -> void:
	mesh_instance.set_instance_shader_parameter("steep_color", new_steep_color)

func set_shore_color(new_shore_color: Color) -> void:
	mesh_instance.set_instance_shader_parameter("shore_color", new_shore_color)

func set_shore_height(new_shore_height: float) -> void:
	mesh_instance.set_instance_shader_parameter("shore_height", new_shore_height)
