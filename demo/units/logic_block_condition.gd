class_name LogicBlockCondition extends RefCounted

enum Comparison {
	EQUALS,
	NOT_EQUALS,
	LESS_THAN,
	GREATER_THAN,
	LESS_THAN_EQUALS,
	GREATER_THAN_EQUALS
}

var condition := Unit.Condition.HP
var comparison := Comparison.EQUALS
var compare_value := 0.0

static func compare(a: float, b: float, how := Comparison.EQUALS) -> bool:
	var met := false
	match how:
		Comparison.EQUALS: met = a == b
		Comparison.NOT_EQUALS: met = a != b
		Comparison.LESS_THAN: met = a < b
		Comparison.GREATER_THAN: met = a > b
		Comparison.LESS_THAN_EQUALS: met = a <= b
		Comparison.GREATER_THAN_EQUALS: met = a >= b
		_: push_warning("(LogicBlockCondition) Invalid comparison: %d" % how)
	return met

func check(value: float) -> bool:
	return compare(value, compare_value, comparison)

func check_unit(unit: Unit) -> bool:
	return compare(unit.condition_value(condition), compare_value, comparison)
