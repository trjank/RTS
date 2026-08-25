class_name UnitLogicCache extends UnitLogicManager

var _last_insert_id := -1
var _loaded_unit_logic: Dictionary[int, UnitLogic] = {}

func size() -> int:
	return _loaded_unit_logic.size()

func get_unit_logic(id: int) -> UnitLogic:
	return _loaded_unit_logic.get(id)

func sync_unit_logic(unit_logic: UnitLogic) -> bool:
	return unit_logic != null and _loaded_unit_logic.get(unit_logic.id) == unit_logic

func save_unit_logic(unit_logic: UnitLogic) -> bool:
	return unit_logic != null and _loaded_unit_logic.get(unit_logic.id) == unit_logic

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
	if unit_logic == null or unit_logic.db != self:
		return false
	_loaded_unit_logic.erase(unit_logic.id)
	unit_logic.db = null
	unit_logic.id = INVALID_ID
	unit_logic_deleted.emit(unit_logic)
	return true
