class_name RadarSignature extends Target

enum State {
	DEAD,
	ALIVE,
	CLOAKED
}

var future_position := Vector2.ZERO

var _state := State.DEAD
var _unit: Unit

func get_state() -> State:
	return _state

func is_alive() -> bool:
	return _state != State.DEAD

func as_unit() -> Unit:
	assert(_state != State.DEAD)
	return _unit
