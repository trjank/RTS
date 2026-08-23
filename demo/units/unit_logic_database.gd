class_name UnitLogicDatabase extends RefCounted

signal unit_logic_created(unit_logic: UnitLogic)
signal unit_logic_deleted(unit_logic: UnitLogic)

const INVALID_ID := -1
const CREATE_TABLE_QUERY := "CREATE TABLE IF NOT EXISTS unit_logic (id INTEGER PRIMARY KEY AUTOINCREMENT, display_name TEXT NOT NULL, blocks BLOB);"

var _loaded_unit_logic: Dictionary[int, UnitLogic] = {}
var _db := SQLite.new()

## NOTE: The database autosaves (no need to call a save function when done)
func load_file(path: String) -> bool:
	_db.path = path
	_loaded_unit_logic.clear()
	return _db.open_db() and _db.query(CREATE_TABLE_QUERY)

func get_unit_logic(id: int) -> UnitLogic:
	if id in _loaded_unit_logic:
		return _loaded_unit_logic[id]
	var results := _db.select_rows("unit_logic", "id == %d" % id, ["*"] )
	return null if results.is_empty() else UnitLogic.from_dict(results[0], true)

func create_unit_logic(unit_logic: UnitLogic) -> bool:
	if unit_logic == null or unit_logic._db != null or not _db.insert_row("unit_logic", unit_logic.to_dict() ):
		return false
	unit_logic._db = weakref(self)
	unit_logic._id = _db.last_insert_rowid
	unit_logic_created.emit(unit_logic)
	return true

func delete_unit_logic(unit_logic: UnitLogic) -> bool:
	if unit_logic == null or not _db.delete_rows("unit_logic", "id == %d" % unit_logic._id):
		return false
	_loaded_unit_logic.erase(unit_logic._id)
	unit_logic._id = INVALID_ID
	unit_logic_deleted.emit(unit_logic)
	return true

func sync_unit_logic(unit_logic: UnitLogic) -> bool:
	if unit_logic == null or not unit_logic._id in _loaded_unit_logic:
		return false
	var results := _db.select_rows("unit_logic", "id == %d" % unit_logic._id, ["*"] )
	return unit_logic.load_dict(results[0] )

func save_unit_logic(unit_logic: UnitLogic) -> bool:
	return unit_logic != null and _db.update_rows("unit_logic", "id == %d" % unit_logic._id, unit_logic.to_dict() )
