class_name UnitLogic extends RefCounted

signal behavior_added
signal behavior_removed

static var DEFAULT := UnitLogic.new():
	set(__): push_error("(UnitLogic) UnitLogic.DEFAULT is immutable!")

var name := "DEFAULT"

var _stack := PackedInt32Array()
var _stack_args := PackedFloat32Array()
#var _conditions := PackedInt32Array()
#var _condition_args := PackedFloat32Array()

func count_behaviors() -> int:
	return _stack.size()

func get_cpu_cost() -> int:
	return _stack.size()

func add_behavior() -> void:
	behavior_added.emit()

func remove_behavior() -> void:
	behavior_removed.emit()

func execute_all(unit: Unit) -> bool:
	if unit == null:
		return false
	var i := 0
	var condition := false
	while not condition:
		condition = unit.check_condition() and unit.issue_command(_stack[i], _stack_args[i] )
	return condition
