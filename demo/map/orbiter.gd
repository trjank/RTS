class_name Orbiter extends Scenery

const GRAVITATIONAL_CONSTANT := 1.0
const MIN_ORBIT_RADIUS := 0.0
const MAX_ORBIT_RADIUS := 100.0
# This is a lower bound to prevent huge or infinite orbital speeds
const MIN_EFFECTIVE_ORBIT_RADIUS := 0.1

var angle := 0.0:
	set = set_angle
var orbit_angle := 0.0:
	set = set_orbit_angle
var orbit_offset := 0.0:
	set = set_orbit_offset
var orbit_radius := MIN_ORBIT_RADIUS:
	set = set_orbit_radius

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

func set_time(new_time: float) -> void:
	time = new_time
	orbit_angle = orbit_offset + time * get_angular_speed()

func set_angle(new_angle: float) -> void:
	angle = new_angle
	_update_rotation()

func set_orbit_angle(new_orbit_angle: float) -> void:
	orbit_angle = fposmod(new_orbit_angle, TAU)
	_update_position()
	_update_rotation()

func set_orbit_radius(new_orbit_radius: float) -> void:
	orbit_radius = clampf(new_orbit_radius, MIN_ORBIT_RADIUS, MAX_ORBIT_RADIUS)
	_update_position()

func set_orbit_offset(new_orbit_offset: float) -> void:
	orbit_offset = fposmod(new_orbit_offset, TAU)
	_update_position()

func _update_rotation() -> void:
	rotation.y = angle - orbit_angle

func _update_position() -> void:
	var position_2d := orbit_radius * Vector2.from_angle(orbit_angle)
	position = Vector3(position_2d.x, 0.0, position_2d.y)

func _ready() -> void:
	super()
	#
	var min_orbit_radius := float(_map.preset.get("min_orbit_radius", MIN_ORBIT_RADIUS) )
	var max_orbit_radius := float(_map.preset.get("max_orbit_radius", MAX_ORBIT_RADIUS) )
	var min_orbit_offset := float(_map.preset.get("min_orbit_offset", 0.0) )
	var max_orbit_offset := float(_map.preset.get("max_orbit_offset", 360.0) )
	orbit_radius = _rng.randf_range(min_orbit_radius, max_orbit_radius)
	orbit_offset = deg_to_rad(_rng.randf_range(min_orbit_offset, max_orbit_offset) ) + TAU * generation_index / generation_count
	angle = rotation.y
