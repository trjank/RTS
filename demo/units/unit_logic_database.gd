class_name UnitLogicDatabase extends UnitLogicManager

const CREATE_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS unit_logic (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	block_bytes BLOB NOT NULL
);"""

var _db := SQLite.new()

static func create(id: int, fallback := TEMPORARY) -> UnitLogicManager:
	var manager := UnitLogicDatabase.new(id)
	return manager if manager.register() else fallback

## NOTE: The database autosaves (no need to call a save function when done)
func load_file(path: String) -> bool:
	_db.path = path
	_loaded_unit_logic.clear()
	return _db.open_db() and _db.query(CREATE_TABLE_QUERY)

func clear() -> void:
	_db.delete_rows("unit_logic", "")
	_loaded_unit_logic.clear()

func delete() -> void:
	pass

func get_loaded_unit_logic() -> Array:
	return _loaded_unit_logic.values()

func get_unit_logic(id: int) -> UnitLogic:
	if id in _loaded_unit_logic:
		return _loaded_unit_logic[id]
	var results := _db.select_rows("unit_logic", "id == %d" % id, ["*"] )
	return null if results.is_empty() else _load_from_dict(results[0] )

func load_unit_logic(limit: int) -> Array:
	assert(_loaded_unit_logic.is_empty(), "Run load_unit_logic BEFORE anything else")
	#
	_db.query("SELECT * FROM unit_logic LIMIT %d;" % limit)
	return _db.query_result.map(_load_from_dict)

func create_unit_logic(unit_logic: UnitLogic) -> bool:
	if unit_logic == null or unit_logic.db != null or not _db.insert_row("unit_logic", unit_logic.to_dict(false) ):
		return false
	unit_logic.db = self
	unit_logic.id = _db.last_insert_rowid
	unit_logic_created.emit(unit_logic)
	return true

func delete_unit_logic(unit_logic: UnitLogic) -> bool:
	if not owns(unit_logic) or not _db.delete_rows("unit_logic", "id == %d" % unit_logic.id):
		return false
	_loaded_unit_logic.erase(unit_logic.id)
	unit_logic.id = 0
	unit_logic.db = null
	unit_logic_deleted.emit(unit_logic)
	return true

func sync_unit_logic(unit_logic: UnitLogic) -> bool:
	if not owns(unit_logic):
		return false
	var results := _db.select_rows("unit_logic", "id == %d" % unit_logic.id, ["*"] )
	return unit_logic.load_dict(results[0], true)

func save_unit_logic(unit_logic: UnitLogic) -> bool:
	return owns(unit_logic) and _db.update_rows("unit_logic", "id == %d" % unit_logic.id, unit_logic.to_dict(false) )

func _load_from_dict(dict: Dictionary) -> UnitLogic:
	var unit_logic := UnitLogic.from_dict(dict, true)
	unit_logic.db = self
	_loaded_unit_logic[unit_logic.id] = unit_logic
	return unit_logic
