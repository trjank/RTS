class_name Target extends RefCounted

const NO_INTERSECTION := -1.0

var global_position: Vector3
var linear_velocity: Vector3
var speed := 0.0

func _init(init_global_position := Vector3.ZERO, init_linear_velocity := Vector3.ZERO) -> void:
	global_position = init_global_position
	linear_velocity = init_linear_velocity

func is_alive() -> bool:
	return true

func hit(_damage: float, _from: Player = null, _penetration := 0.0) -> void:
	pass # (override this method)

func drain_energy(_energy_drain: float) -> void:
	pass # (override this method)

func get_intersection_point(intersection_time: float) -> Vector3:
	return global_position + intersection_time * linear_velocity

func get_approx_intersect_time(other_target: Target) -> float:
	return other_target.get_approx_intersect_time_from(global_position, speed)

func get_intersect_time(other_target: Target) -> float:
	return other_target.get_intersect_time_from(global_position, speed)

func get_approx_intersect_time_from(from: Vector3, other_speed: float) -> float:
	return from.distance_to(global_position) / other_speed

func get_intersect_time_from(from: Vector3, other_speed: float) -> float:
	# Need to apply the quadratic formula
	var dx := global_position - from
	var v_dot_dx := linear_velocity.dot(dx)
	var dspeed_sq := other_speed * other_speed - linear_velocity.length_squared()
	var discriminant := v_dot_dx * v_dot_dx + dspeed_sq * dx.length_squared()
	# Return one of the solutions, if it exists
	return (v_dot_dx + sqrt(discriminant) ) / dspeed_sq if 0 <= discriminant else NO_INTERSECTION
