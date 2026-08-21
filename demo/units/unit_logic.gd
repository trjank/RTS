class_name UnitLogic extends RefCounted

signal block_added
signal block_removed

const MAX_NUM_BLOCKS := 100

static var DEFAULT := UnitLogic.new():
	set(__): push_error("(UnitLogic) UnitLogic.DEFAULT is immutable!")

var display_name := "DEFAULT"

var _blocks: Array[LogicBlock] = []

func count_blocks() -> int:
	return _blocks.size()

func calculate_cpu_cost() -> int:
	return _blocks.reduce(func(sum: int, block: LogicBlock) -> int: return sum + block.calculate_cpu_cost(), 0)

func add_block() -> bool:
	if MAX_NUM_BLOCKS <= _blocks.size():
		return false
	block_added.emit()
	return true

func remove_block() -> void:
	block_removed.emit()

func execute(unit: Unit) -> bool:
	assert(unit != null)
	#
	var i := 0
	while not _blocks[i].execute(unit):
		i += 1
	return i < _blocks.size()
