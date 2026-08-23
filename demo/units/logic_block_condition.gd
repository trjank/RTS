class_name LogicBlockCondition extends RefCounted

enum Comparison {
	EQUALS,
	NOT_EQUALS,
	LESS_THAN,
	GREATER_THAN,
	LESS_THAN_EQUALS,
	GREATER_THAN_EQUALS
}

const BYTES := Bytes.U64 + Bytes.U8 + Bytes.FLOAT

var condition := Unit.Condition.HP
var comparison := Comparison.EQUALS
var compare_value := 0.0

static func compare(a: float, b: float, operation := Comparison.EQUALS) -> bool:
	match operation:
		Comparison.EQUALS: return a == b
		Comparison.NOT_EQUALS: return a != b
		Comparison.LESS_THAN: return a < b
		Comparison.GREATER_THAN: return a > b
		Comparison.LESS_THAN_EQUALS: return a <= b
		Comparison.GREATER_THAN_EQUALS: return a >= b
		_: push_warning("Invalid operation: %d" % operation)
	return false

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
