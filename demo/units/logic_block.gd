class_name LogicBlock extends RefCounted

signal edited
signal condition_added(condition: LogicBlockCondition)
signal condition_removed(condition: LogicBlockCondition)

const MAX_NUM_CONDITIONS := 10
const BYTES := Bytes.U16 + Bytes.U64 + Bytes.FLOAT + Bytes.FLOAT

var behavior := Unit.Behavior.NONE:
	set = set_behavior
var arg1 := 0.0:
	set = set_arg1
var arg2 := 0.0:
	set = set_arg2

var _conditions: Array[LogicBlockCondition] = []

func count_conditions() -> int:
	return _conditions.size()

func calculate_cpu_cost() -> int:
	return 1 + _conditions.size()

func calculate_size_bytes() -> int:
	return BYTES + LogicBlockCondition.BYTES * _conditions.size()

func get_condition(i: int) -> LogicBlockCondition:
	return _conditions[i]

func set_behavior(new_behavior: Unit.Behavior) -> void:
	if new_behavior == behavior:
		return
	behavior = new_behavior
	edited.emit()

func set_arg1(new_arg1: float) -> void:
	arg1 = new_arg1
	edited.emit()

func set_arg2(new_arg2: float) -> void:
	arg2 = new_arg2
	edited.emit()

func add_condition() -> LogicBlockCondition:
	if MAX_NUM_CONDITIONS <= _conditions.size():
		return null
	var condition := LogicBlockCondition.new()
	_conditions.push_back(condition)
	condition_added.emit(condition)
	condition.edited.connect(edited.emit)
	edited.emit()
	return condition

func clear() -> void:
	if _conditions.is_empty():
		return
	_conditions.clear()
	edited.emit()

func remove_condition(i: int) -> void:
	var condition: LogicBlockCondition = _conditions.pop_at(i)
	if condition == null:
		return
	condition.edited.disconnect(edited.emit)
	condition_removed.emit(condition)
	edited.emit()

func check_conditions(unit: Unit) -> bool:
	var met := 0
	while met < _conditions.size() and _conditions[met].check_unit(unit):
		met += 1
	return met == _conditions.size()

func execute(unit: Unit) -> bool:
	return check_conditions(unit) and unit.issue_command(behavior, arg1, arg2)

func serialize(buffer: StreamPeerBuffer) -> void:
	var end_ptr := buffer.get_position() + calculate_size_bytes()
	buffer.put_16(calculate_size_bytes() )
	buffer.put_u64(behavior)
	buffer.put_float(arg1)
	buffer.put_float(arg2)
	#
	for condition in _conditions:
		condition.serialize(buffer)
	assert(buffer.get_position() == end_ptr)

func deserialize(buffer: StreamPeerBuffer) -> void:
	var end_ptr := buffer.get_position() + buffer.get_u16()
	behavior = buffer.get_u64() as Unit.Behavior
	arg1 = buffer.get_float()
	arg2 = buffer.get_float()
	_conditions.clear()
	#
	while buffer.get_position() < end_ptr and buffer.get_available_bytes() != 0:
		add_condition().deserialize(buffer)
	assert(buffer.get_position() == end_ptr)
