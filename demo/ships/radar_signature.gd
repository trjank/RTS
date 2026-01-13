class_name RadarSignature2 extends Target2

enum State {
	DEAD,
	ALIVE,
	CLOAKED
}

var future_position := Vector2.ZERO

var _state := State.DEAD
var _unit: Unit2

func get_state() -> State:
	return _state

func is_alive() -> bool:
	return _state != State.DEAD

func as_unit() -> Unit2:
	assert(_state != State.DEAD)
	return _unit
