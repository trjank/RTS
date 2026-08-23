class_name UnitLogic extends RefCounted

signal cleared
signal block_added(block: LogicBlock)
signal block_removed(block: LogicBlock)

const PROPERTIES: Dictionary[String, Variant.Type] = {
	"display_name": TYPE_STRING,
	"block_bytes": TYPE_PACKED_BYTE_ARRAY
}
const MAX_NUM_BLOCKS := 100

static var NONE := UnitLogic.new():
	set(__): push_error("UnitLogic.NONE is immutable!")
static var DEFAULT := UnitLogic.new():
	set(__): push_error("UnitLogic.DEFAULT is immutable!")

var block_bytes: PackedByteArray:
	set = set_block_bytes
var display_name := "DEFAULT"

var _id := UnitLogicDatabase.INVALID_ID
var _db: WeakRef
var _blocks: Array[LogicBlock] = []

static func _static_init() -> void:
	DEFAULT.add_block().behavior = Unit.Behavior.ATTACK

static func from_dict(dict: Dictionary, always_copy := false) -> UnitLogic:
	var unit_logic := UnitLogic.new()
	return unit_logic if unit_logic.load_dict(dict) or always_copy else DEFAULT

func to_dict() -> Dictionary:
	return TypeChecker.to_dict(self, PROPERTIES)

func load_dict(dict: Dictionary) -> bool:
	return TypeChecker.load_dict(self, dict, PROPERTIES)

func count_blocks() -> int:
	return _blocks.size()

func calculate_cpu_cost() -> int:
	return _blocks.reduce(func(sum: int, block: LogicBlock) -> int: return sum + block.calculate_cpu_cost(), 0)

func get_id() -> int:
	return _id

func get_db() -> UnitLogicDatabase:
	return _db.get_ref()

func get_block(i: int) -> LogicBlock:
	return _blocks[i]

func set_block_bytes(new_block_bytes: PackedByteArray) -> void:
	block_bytes = new_block_bytes

func sync() -> bool:
	var db := get_db()
	return db != null and db.sync_unit_logic(self)

func save() -> bool:
	var db := get_db()
	return db != null and db.save_unit_logic(self)

func delete() -> bool:
	var db := get_db()
	return db != null and db.delete_unit_logic(self)

func clear() -> void:
	_blocks.clear()
	cleared.emit()

func add_block() -> LogicBlock:
	if MAX_NUM_BLOCKS <= _blocks.size():
		return null
	var block := LogicBlock.new()
	_blocks.push_back(block)
	block_added.emit(block)
	return block

func remove_block() -> void:
	block_removed.emit()

func execute(unit: Unit) -> bool:
	assert(unit != null)
	#
	var i := 0
	while i < _blocks.size() and not _blocks[i].execute(unit):
		i += 1
	return i < _blocks.size()

func serialize() -> void:
	var buffer := StreamPeerBuffer.new()
	#
	for block in _blocks:
		block.serialize(buffer)
	block_bytes = buffer.data_array

func deserialize(bytes: PackedByteArray) -> void:
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = bytes
	clear()
	while buffer.get_available_bytes() != 0:
		add_block().deserialize(buffer)
	block_bytes = bytes
