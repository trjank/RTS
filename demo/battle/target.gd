class_name Target extends RefCounted

const NO_INTERSECTION := -1.0

var position: Vector2
var velocity: Vector2
var speed := 0.0

func _init(init_position := Vector2.ZERO, init_velocity := Vector2.ZERO) -> void:
	position = init_position
	velocity = init_velocity

func is_alive() -> bool:
	return true

func get_intersection_point(intersection_time: float) -> Vector2:
	return position + intersection_time * velocity

func get_approx_intersect_time(other_target: Target) -> float:
	return other_target.get_approx_intersect_time_from(position, speed)

func get_intersect_time(other_target: Target) -> float:
	return other_target.get_intersect_time_from(position, speed)

func get_approx_intersect_time_from(from: Vector2, other_speed: float) -> float:
	return from.distance_to(position) / other_speed

func get_intersect_time_from(from: Vector2, other_speed: float) -> float:
	# Need to apply the quadratic formula
	var dx := position - from
	var v_dot_dx := velocity.dot(dx)
	var dspeed_sq := other_speed * other_speed - velocity.length_squared()
	var discriminant := v_dot_dx * v_dot_dx + dspeed_sq * dx.length_squared()
	# Return one of the solutions, if it exists
	return (v_dot_dx + sqrt(discriminant) ) / dspeed_sq if 0 <= discriminant else NO_INTERSECTION
