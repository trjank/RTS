@tool
class_name Orbiter extends Scenery

const GRAVITATIONAL_CONSTANT := 0.1
const MIN_ORBIT_RADIUS := 0.0
const MAX_ORBIT_RADIUS := 1.0e5
# This is a lower bound to prevent huge or infinite orbital speeds
const MIN_EFFECTIVE_ORBIT_RADIUS := 0.1

@export_range(0.0, TAU, 0.01) var angle := 0.0:
	set = set_angle
@export_range(0.0, TAU, 0.01) var orbit_offset := 0.0:
	set = set_orbit_offset
@export var orbit_radius := MIN_ORBIT_RADIUS:
	set = set_orbit_radius

var _orbit_longitude := 0.0

func get_orbit_center() -> Scenery:
	return get_parent() as Scenery

func get_orbit_mass() -> float:
	var center := get_orbit_center()
	return center.mass if center != null else MIN_MASS

func get_effective_orbit_radius() -> float:
	return maxf(orbit_radius, MIN_EFFECTIVE_ORBIT_RADIUS)

func get_speed() -> float:
	return GRAVITATIONAL_CONSTANT * get_orbit_mass() / get_effective_orbit_radius()

func get_angular_speed() -> float:
	return get_speed() / get_effective_orbit_radius()

func get_orbit_longitude() -> float:
	return _orbit_longitude

func set_angle(new_angle: float) -> void:
	angle = new_angle
	_update_rotation()

func set_time(new_time: float) -> void:
	super(new_time)
	#
	_orbit_longitude = orbit_offset + time * get_angular_speed()
	_update_position()
	_update_rotation()

func set_orbit_radius(new_orbit_radius: float) -> void:
	orbit_radius = clampf(new_orbit_radius, MIN_ORBIT_RADIUS, MAX_ORBIT_RADIUS)
	_update_position()

func set_orbit_offset(new_orbit_offset: float) -> void:
	orbit_offset = fposmod(new_orbit_offset, TAU)
	_update_position()

func _save_orbit_data(layer_variables := {} ) -> void:
	layer_variables["orbit_radius"] = orbit_radius
	layer_variables["orbit_offset"] = orbit_offset

func use_layer_variables(layer_variables := {} ) -> void:
	if index == 0:
		return _save_orbit_data(layer_variables)
	var count_offset := index * (TAU / count)
	orbit_radius = layer_variables["orbit_radius"]
	orbit_offset = layer_variables["orbit_offset"] + count_offset

func generate_from_map() -> void:
	super()
	#
	orbit_radius = generate_randf_range("min_orbit_radius", "max_orbit_radius", MIN_ORBIT_RADIUS, MAX_ORBIT_RADIUS)
	orbit_offset = generate_randf_radians("min_orbit_offset", "max_orbit_offset")
	angle = rotation.y

func _update_rotation() -> void:
	rotation.y = angle - _orbit_longitude

func _update_position() -> void:
	var position_2d := orbit_radius * Vector2.from_angle(_orbit_longitude)
	position = Vector3(position_2d.x, 0.0, position_2d.y)
