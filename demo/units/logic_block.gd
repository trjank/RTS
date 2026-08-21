class_name LogicBlock extends RefCounted

var behavior := Unit.Behavior.NONE
var arg1 := 0.0
var arg2 := 0.0
var conditions: Array[LogicBlockCondition] = []

func calculate_cpu_cost() -> int:
	return 1 + conditions.size()

func check_conditions(unit: Unit) -> bool:
	var met := 0
	while conditions[met].check_unit(unit) and met < conditions.size():
		met += 1
	return met == conditions.size()

func execute(unit: Unit) -> bool:
	return check_conditions(unit) and unit.issue_command(behavior, arg1, arg2)
