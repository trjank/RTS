class_name UnitLogicManager extends RefCounted

signal unit_logic_created(unit_logic: UnitLogic)
signal unit_logic_deleted(unit_logic: UnitLogic)

# Keep ID_BITS below 64 so UnitLogic uids fit in a single integer
# (See UnitLogic for how unique global ids are constructed)
const ID_BITS := 16
const MIN_ID := 0
const MAX_ID := 2 ** ID_BITS - 1

static var _registry: Dictionary[int, UnitLogicManager] = {}

var _id: int
var _last_insert_id := -1
var _loaded_unit_logic: Dictionary[int, UnitLogic] = {}

static func from_id(id: int) -> UnitLogicManager:
	return _registry.get(id)

func _init(const_id: int) -> void:
	_id = clampi(const_id, MIN_ID, MAX_ID)

func get_id() -> int:
	return _id

## Exposes the database globally (must have a unique id to work)
func register() -> bool:
	return not _id in _registry and _registry.set(_id, self)

func clear() -> void:
	_loaded_unit_logic.clear()

func delete() -> void:
	clear()

func owns(unit_logic: UnitLogic) -> bool:
	return unit_logic != null and unit_logic.db == self

func get_unit_logic(id: int) -> UnitLogic:
	return _loaded_unit_logic.get(id)

## NOTE: This does not automatically update unit_logic.saved (use unit_logic.sync() instead for that)
func sync_unit_logic(unit_logic: UnitLogic) -> bool:
	return owns(unit_logic)

## NOTE: This does not automatically update unit_logic.saved (use unit_logic.save() instead for that)
func save_unit_logic(unit_logic: UnitLogic) -> bool:
	return owns(unit_logic)

func create_unit_logic(unit_logic: UnitLogic) -> bool:
	if unit_logic == null or unit_logic.db != null:
		return false
	unit_logic.db = self
	unit_logic.id = _last_insert_id + 1
	_last_insert_id = unit_logic.id
	_loaded_unit_logic[unit_logic.id] = unit_logic
	unit_logic_created.emit(unit_logic)
	return true

func delete_unit_logic(unit_logic: UnitLogic) -> bool:
	if not owns(unit_logic):
		return false
	_loaded_unit_logic.erase(unit_logic.id)
	unit_logic.db = null
	unit_logic.id = -1
	unit_logic_deleted.emit(unit_logic)
	return true
