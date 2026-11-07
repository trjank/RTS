class_name ShipDatabase extends ShipManager

const CREATE_SHIPS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS ships (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	priority INTEGER NOT NULL,
	name TEXT NOT NULL,
	grid_width INTEGER NOT NULL,
	grid_height INTEGER NOT NULL,
	unit_logic_uid INTEGER NOT NULL,
	thumbnail_bytes BLOB,
	part_bytes BLOB,
	extra_bytes BLOB
);
CREATE UNIQUE INDEX IF NOT EXISTS ship_priority ON ships (priority);"""
const CREATE_FLEETS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS fleets (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	priority INTEGER NOT NULL,
	size INTEGER NOT NULL,
	name TEXT NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS fleet_priority ON fleets (priority);"""
const CREATE_FLEET_SLOTS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS fleet_slots (
	fleet_id INTEGER,
	ship_id INTEGER,
	slot INTEGER NOT NULL,
	PRIMARY KEY (fleet_id, slot)
);"""
const CREATE_PRIORITY_TRIGGERS_QUERY = """
CREATE TRIGGER IF NOT EXISTS initialize_ship_priority
AFTER INSERT ON ships
BEGIN
    UPDATE ships
    SET priority = NEW.id
    WHERE id = NEW.id;
END;
CREATE TRIGGER IF NOT EXISTS initialize_fleet_priority
AFTER INSERT ON fleets
BEGIN
    UPDATE fleets
    SET priority = NEW.id
    WHERE id = NEW.id;
END;"""
const BLOB_COLUMNS: PackedStringArray = ["thumbnail_bytes", "part_bytes", "extra_bytes"]

var _db := SQLite.new()
var _load_ship_priority := -1
var _load_fleet_priority := -1

func load_file(path: String) -> bool:
	_db.path = path
	_loaded_ships.clear()
	_loaded_fleets.clear()
	return _db.open_db() and _db.query(CREATE_SHIPS_TABLE_QUERY) and _db.query(CREATE_FLEETS_TABLE_QUERY) and _db.query(CREATE_FLEET_SLOTS_TABLE_QUERY) and _db.query(CREATE_PRIORITY_TRIGGERS_QUERY)

## Loads highest priority ships that have not already been loaded in
func load_ships(limit: int) -> Array:
	_db.query_with_bindings("SELECT * FROM ships WHERE priority > ? ORDER BY priority ASC LIMIT ?", [_load_ship_priority, limit] )
	var ships := _db.query_result.map(_load_ship_from_dict)
	if not ships.is_empty():
		_load_ship_priority = ships[-1].priority
	return ships

## Loads highest priority fleets that have not already been loaded in
func load_fleets(limit: int) -> Array:
	_db.query_with_bindings("SELECT * FROM fleets WHERE priority > ? ORDER BY priority ASC LIMIT ?", [_load_fleet_priority, limit] )
	var fleets := _db.query_result.map(_load_fleet_from_dict)
	if not fleets.is_empty():
		_load_fleet_priority = fleets[-1].priority
	return fleets

func clear() -> void:
	_db.delete_rows("ships", "")
	_db.delete_rows("fleets", "")
	_db.delete_rows("fleet_slots", "")
	_loaded_ships.clear()
	_loaded_fleets.clear()

func delete() -> void:
	pass

func get_ship(id: int) -> ShipData:
	if id in _loaded_ships:
		return _loaded_ships[id]
	var results := _db.select_rows("ships", "id == %d" % id, ["*"] )
	return null if results.is_empty() else _load_ship_from_dict(results[0] )

func get_fleet(id: int) -> Fleet:
	if id in _loaded_fleets:
		return _loaded_fleets[id]
	var results := _db.select_rows("fleets", "id == %d" % id, ["*"] )
	return null if results.is_empty() else _load_fleet_from_dict(results[0] )

func create_ship(ship: ShipData) -> bool:
	if ship == null or ship.db != null or not _db.insert_row("ships", ship.to_dict(false) ):
		return false
	ship.db = self
	ship.id = _db.last_insert_rowid
	ship.priority = _db.last_insert_rowid
	ship_created.emit(ship)
	return true

func create_fleet(fleet: Fleet) -> bool:
	if fleet == null or fleet.db != null or not _db.insert_row("fleets", fleet.to_dict(false) ):
		return false
	fleet.db = self
	fleet.id = _db.last_insert_rowid
	fleet.priority = _db.last_insert_rowid
	fleet_created.emit(fleet)
	return true

func sync_ship(ship: ShipData) -> bool:
	if ship == null or not ship.id in _loaded_ships:
		return false
	var results := _db.select_rows("ships", "ship_id == %d" % ship.id, ["*"] )
	return not results.is_empty() and ship.load_dict(results[0] )

func sync_fleet_metadata(fleet: Fleet) -> bool:
	if fleet == null or not fleet.id in _loaded_fleets:
		return false
	var results := _db.select_rows("fleets", "fleet_id == %d" % fleet.id, ["*"] )
	var result: Dictionary = results[0]
	fleet.fleet.name = result["name"]
	return fleet.fleet.ships.resize(result["size"] ) == OK

func sync_fleet_ships(fleet: Fleet) -> bool:
	var results := _db.select_rows("fleet_slots", "fleet_id == %d" % fleet.id, ["*"] )
	#
	for result in results:
		fleet.set_ship(result["slot"], get_ship(result["ship_id"] ) )
	return fleet.size == results.size()

func sync_fleet(fleet: Fleet) -> bool:
	return sync_fleet_metadata(fleet) and sync_fleet_ships(fleet)

func save_ship(ship: ShipData) -> bool:
	return ship != null and _db.update_rows("ships", "id == %d" % ship.id, ship.to_dict(false) )

func save_fleet_metadata(fleet: Fleet) -> bool:
	return fleet != null and _db.update_rows("fleets", "id == %d" % fleet.id, fleet.to_dict(false) )

func save_fleet_ships(fleet: Fleet) -> bool:
	if fleet == null or _loaded_fleets.get(fleet.id) != fleet:
		return false
	var ships := range(fleet.size).filter(fleet.has_ship_in_slot).map(_fleet_slot_to_dict.bind(fleet) )
	_db.delete_rows("fleet_slots", "fleet_id == %d" % fleet.id)
	return _db.insert_rows("fleet_slots", ships)

func save_fleet(fleet: Fleet) -> bool:
	return fleet != null and save_fleet_ships(fleet) and save_fleet_metadata(fleet)

func delete_ship(ship: ShipData) -> bool:
	return ship != null and _db.delete_rows("ships", "id == %d" % ship.id) and _db.delete_rows("fleet_slots", "ship_id == %d" % ship.id) and _loaded_ships.erase(ship.id)

func delete_fleet(fleet: Fleet) -> bool:
	return fleet != null and _db.delete_rows("fleets", "id == %d" % fleet.id) and _db.delete_rows("fleet_slots", "fleet_id == %d" % fleet.id) and _loaded_fleets.erase(fleet.id)

func _fleet_slot_to_dict(slot: int, fleet: Fleet) -> Dictionary:
	assert(fleet._ships[slot].db == fleet.db, "Mismatched database for fleet#%d and ship in slot %d" % [fleet.id, slot] )
	#
	return {"fleet_id": fleet.id, "ship_id": fleet._ships[slot].id, "slot": slot}

func _load_ship_from_dict(dict: Dictionary) -> ShipData:
	for column in BLOB_COLUMNS:
		dict[column] = dict[column] if dict[column] != null else PackedByteArray()
	var ship := ShipData.from_dict(dict, true)
	ship.db = self
	_loaded_ships[ship.id] = ship
	ship_created.emit(ship)
	return ship

func _load_fleet_from_dict(result: Dictionary) -> Fleet:
	var fleet := Fleet.from_dict(result, true)
	fleet.db = self
	sync_fleet_ships(fleet)
	_loaded_fleets[fleet.id] = fleet
	fleet_created.emit(fleet)
	return fleet
