class_name RadarSignature extends Target

enum State {
	DEAD,
	ALIVE,
	CLOAKED
}

var _state := State.DEAD
var _unit: Unit

## NOTE: This is useful for Array.map
static func to_unit(radar_signature: RadarSignature) -> Unit:
	return radar_signature.as_unit() 

func is_alive() -> bool:
	return _state != State.DEAD

func get_state() -> State:
	return _state

func get_future_global_position() -> Vector3:
	var stationary := _state == State.DEAD or _unit.is_queue_empty()
	return global_position if stationary else _unit.get_waypoint(-1).global_position

func as_unit() -> Unit:
	assert(_state != State.DEAD)
	#
	return _unit

func hit(damage: float, from: Player = null, penetration := 0.0) -> void:
	if is_alive():
		_unit.hit(damage, from, penetration)

func drain_energy(energy_drain: float) -> void:
	if is_alive():
		_unit.drain_energy(energy_drain)
