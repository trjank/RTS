class_name LogicBlockCondition extends RefCounted

signal edited

enum Comparison {
	LESS_THAN_EQUALS,
	GREATER_THAN_EQUALS
}

const BYTES := Bytes.U64 + Bytes.U8 + Bytes.FLOAT

var condition := Unit.Condition.HP:
	set = set_condition
var comparison := Comparison.LESS_THAN_EQUALS:
	set = set_comparison
var compare_value := 0.0:
	set = set_compare_value

static func compare(a: float, b: float, operation := Comparison.LESS_THAN_EQUALS) -> bool:
	return a <= b if operation == Comparison.LESS_THAN_EQUALS else a >= b

func set_condition(new_condition: Unit.Condition) -> void:
	if new_condition == condition:
		return
	condition = new_condition
	edited.emit()

func set_comparison(new_comparison: Comparison) -> void:
	if new_comparison == comparison:
		return
	comparison = new_comparison
	edited.emit()

func set_compare_value(new_compare_value: float) -> void:
	compare_value = new_compare_value
	edited.emit()

func check(value: float) -> bool:
	return compare(value, compare_value, comparison)

func check_unit(unit: Unit) -> bool:
	return compare(unit.condition_value(condition), compare_value, comparison)

func serialize(buffer: StreamPeerBuffer) -> void:
	buffer.put_u64(condition)
	buffer.put_8(comparison)
	buffer.put_float(compare_value)

func deserialize(buffer: StreamPeerBuffer) -> void:
	condition = buffer.get_u64() as Unit.Condition
	comparison = buffer.get_u8() as Comparison
	compare_value = buffer.get_float()
