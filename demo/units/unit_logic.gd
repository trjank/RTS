class_name UnitLogic extends RefCounted

signal cleared
signal save_changed(is_saved: bool)
signal block_added(block: LogicBlock)
signal block_removed(block: LogicBlock)
signal renamed(new_name: String)

static var PROPERTIES: Dictionary[String, Variant.Type] = {
	"name": TYPE_STRING,
	"block_bytes": TYPE_PACKED_BYTE_ARRAY
}
static var DB_PROPERTIES: Dictionary[String, Variant.Type] = {
	"id": TYPE_INT
}

const ID_BITS := 64 - UnitLogicManager.ID_BITS
const MIN_ID := 0
const MAX_ID := 2 ** ID_BITS - 1
const MAX_NUM_BLOCKS := 100
const MAX_NAME_LENGTH := 100
const DUMMY_BYTE := 137

static var NONE := UnitLogic.new():
	set(__): push_error("UnitLogic.NONE is immutable!")
static var DEFAULT := UnitLogic.new():
	set(__): push_error("UnitLogic.DEFAULT is immutable!")

var name := "":
	set = set_name
var saved := true:
	set = set_saved
var id := 0:
	set = set_id
var db: UnitLogicManager:
	get = get_db, set = set_db
var block_bytes: PackedByteArray:
	get = get_block_bytes, set = deserialize

var _db: WeakRef = weakref(null)
var _blocks: Array[LogicBlock] = []
var _block_bytes: PackedByteArray = [DUMMY_BYTE]

static func _static_init() -> void:
	DEFAULT.add_block().behavior = Unit.Behavior.ATTACK
	DB_PROPERTIES.merge(PROPERTIES)

static func from_uid(uid: int) -> UnitLogic:
	var static_db := UnitLogicManager.from_id(uid & UnitLogicManager.MAX_ID)
	return static_db.get_unit_logic(uid >> UnitLogicManager.ID_BITS) if static_db != null else null

static func from_dict(dict: Dictionary, use_id := false, default := DEFAULT) -> UnitLogic:
	var unit_logic := UnitLogic.new()
	return unit_logic if unit_logic.load_dict(dict, use_id) else default

func to_dict(use_id := false) -> Dictionary:
	return TypeChecker.to_dict(self, DB_PROPERTIES if use_id else PROPERTIES)

func load_dict(dict: Dictionary, use_id := false) -> bool:
	return TypeChecker.load_dict(self, dict, DB_PROPERTIES if use_id else PROPERTIES)

func count_blocks() -> int:
	return _blocks.size()

func calculate_cpu_cost() -> int:
	return _blocks.reduce(func(sum: int, block: LogicBlock) -> int: return sum + block.calculate_cpu_cost(), 0)

func get_block_bytes() -> PackedByteArray:
	return _block_bytes

func get_db() -> UnitLogicManager:
	return _db.get_ref()

func get_block(i: int) -> LogicBlock:
	return _blocks[i]

func get_uid() -> int:
	return (db.get_id() if db != null else 0) | (id << UnitLogicManager.ID_BITS)

func set_id(new_id: int) -> void:
	id = clampi(new_id, MIN_ID, MAX_ID)

func set_db(new_db: UnitLogicManager) -> void:
	_db = weakref(new_db)

func set_saved(new_saved: bool) -> void:
	if new_saved == saved:
		return
	saved = new_saved
	save_changed.emit(saved)

## For one-line set and save do: var saved := set_name(..) and save()
func set_name(new_name: String) -> bool:
	new_name = new_name.left(MAX_NAME_LENGTH)
	if name == new_name:
		return false
	name = new_name
	saved = false
	renamed.emit(new_name)
	return true

func sync(lazy := true) -> bool:
	saved = (saved and lazy) or (db != null and db.sync_unit_logic(self) )
	return saved

func save(lazy := true) -> bool:
	saved = (saved and lazy) or (db != null and db.save_unit_logic(self) )
	return saved

func delete() -> bool:
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
	block.edited.connect(on_block_edited)
	on_block_edited()
	return block

func find_block(block: LogicBlock) -> int:
	return _blocks.find(block)

func remove_block(i: int) -> void:
	block_removed.emit(_blocks.pop_at(i) )
	on_block_edited()

func on_block_edited() -> void:
	saved = false

func execute(unit: Unit) -> bool:
	assert(unit != null)
	#
	var i := 0
	while i < _blocks.size() and not _blocks[i].execute(unit):
		i += 1
	return i < _blocks.size()

func serialize(lazy := true) -> bool:
	if saved and lazy:
		return true
	var buffer := StreamPeerBuffer.new()
	buffer.put_u8(DUMMY_BYTE)
	#
	for block in _blocks:
		block.serialize(buffer)
	_block_bytes = buffer.data_array
	return not block_bytes.is_empty()

func deserialize(bytes: PackedByteArray) -> void:
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = bytes
	if buffer.get_u8() != DUMMY_BYTE:
		push_warning("Wrong dummy byte (bytes may be invalid)")
	clear()
	while buffer.get_available_bytes() != 0:
		add_block().deserialize(buffer)
	_block_bytes = bytes
	saved = true
