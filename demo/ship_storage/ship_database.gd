class_name ShipDatabase extends RefCounted

# DO NOT CHANGE THESE TABLE LAYOUTS
const CREATE_SHIPS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS ships (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	grid_width INTEGER NOT NULL,
	grid_height INTEGER NOT NULL,
	image_width INTEGER NOT NULL,
	image_height INTEGER NOT NULL,
	parts BLOB,
	image BLOB
);
"""
const CREATE_FLEETS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS fleets (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	size INTEGER NOT NULL,
	name TEXT NOT NULL
);
"""
const CREATE_FLEET_SLOTS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS fleet_slots (
	ship_id INTEGER PRIMARY KEY,
	fleet_id INTEGER,
	slot INTEGER NOT NULL
);
"""
const ALL_COLUMNS := ["*"]

var part_manager: PartManager

# NOTE: ShipDataIDs and FleetIDs kept unique to prevent bugs and wasteful copying
var _loaded_ships: Dictionary[int, ShipDataID] = {}
var _loaded_fleets: Dictionary[int, FleetID] = {}
var _db := SQLite.new()

func load_file(path: String) -> bool:
	_db.path = path
	_loaded_ships.clear()
	_loaded_fleets.clear()
	return _db.open_db() \
	and _db.query(CREATE_SHIPS_TABLE_QUERY) \
	and _db.query(CREATE_FLEETS_TABLE_QUERY) \
	and _db.query(CREATE_FLEET_SLOTS_TABLE_QUERY)

func load_ships(limit: int) -> Array:
	assert(_loaded_ships.is_empty(), "Run load_ships BEFORE anything else")
	_db.query("SELECT * FROM ships LIMIT %d;" % limit)
	return _db.query_result.map(_load_ship)

func load_fleets(limit: int) -> Array:
	assert(_loaded_fleets.is_empty(), "Run load_fleets BEFORE anything else")
	_db.query("SELECT * FROM fleets LIMIT %d;" % limit)
	return _db.query_result.map(_load_fleet)

func get_loaded_ships() -> Array:
	return _loaded_ships.values()

func get_loaded_fleets() -> Array:
	return _loaded_fleets.values()

func _load_ship(result: Dictionary) -> ShipDataID:
	var ship_id: int = result["id"]
	var ship := ShipDataID.new(_result_to_ship(result), self, ship_id)
	_loaded_ships[ship_id] = ship
	return ship

func _load_fleet(result: Dictionary) -> FleetID:
	var fleet_id: int = result["id"]
	var fleet := FleetID.new(_result_to_fleet(result), self, fleet_id)
	_loaded_fleets[fleet_id] = fleet
	return fleet

func get_ship(ship_id: int) -> ShipDataID:
	if ship_id in _loaded_ships:
		return _loaded_ships[ship_id]
	var results := _db.select_rows("ships", "id == %d" % ship_id, ALL_COLUMNS)
	return null if results.is_empty() else _load_ship(results[0] )

func get_fleet(fleet_id: int) -> FleetID:
	if fleet_id in _loaded_fleets:
		return _loaded_fleets[fleet_id]
	var results := _db.select_rows("fleets", "id == %d" % fleet_id, ALL_COLUMNS)
	return null if results.is_empty() else _load_fleet(results[0] )

func create_ship(ship: ShipData) -> ShipDataID:
	if ship == null or not _db.insert_row("ships", _ship_to_query(ship) ):
		return null
	var ship_id := _db.last_insert_rowid
	return ShipDataID.new(ship, self, ship_id)

func create_fleet(fleet: Fleet) -> FleetID:
	if fleet == null or not _db.insert_row("fleets", _fleet_to_query(fleet) ):
		return null
	var fleet_id := _db.last_insert_rowid
	return FleetID.new(fleet, self, fleet_id)

func sync_ship(ship: ShipDataID) -> bool:
	if ship == null or not ship.get_id() in _loaded_ships:
		return false
	var results := _db.select_rows("ships", "ship_id == %d" % ship.get_id(), ALL_COLUMNS)
	ship.ship_data = _result_to_ship(results[0] )
	return true

func sync_fleet_metadata(fleet: FleetID) -> bool:
	if fleet == null or not fleet.get_id() in _loaded_fleets:
		return false
	var results := _db.select_rows("fleets", "fleet_id == %d" % fleet.get_id(), ALL_COLUMNS)
	var result: Dictionary = results[0]
	fleet.fleet.name = result["name"]
	return fleet.fleet.ships.resize(result["size"] ) == OK

func sync_fleet_ships(fleet: FleetID) -> bool:
	var results := _db.select_rows("fleet_slots", "fleet_id == %d" % fleet.get_id(), ALL_COLUMNS)
	return results.all(_sync_fleet_ship.bind(fleet.fleet) )

func _sync_fleet_ship(result: Dictionary, fleet: Fleet) -> bool:
	return fleet.set_ship(result["slot"], get_ship(result["ship_id"] ) )

func sync_fleet(fleet: FleetID) -> bool:
	return sync_fleet_metadata(fleet) and sync_fleet_ships(fleet)

func save_ship(ship: ShipDataID) -> bool:
	return ship != null and _db.update_rows("ships", "id == %d" % ship.id, _ship_to_query(ship.ship_data) )

func save_fleet_metadata(fleet: FleetID) -> bool:
	return fleet != null and _db.update_rows("fleets", "id == %d" % fleet.id, _fleet_to_query(fleet.fleet) )

func save_fleet_ships(fleet: FleetID) -> bool:
	if fleet == null:
		return false
	_db.delete_rows("fleet_slots", "fleet_id == %d" % fleet.id)
	var ships := range(fleet.fleet.size() ) \
		.filter(fleet.fleet.has_ship_in_slot) \
		.map(_fleet_slot_to_query.bind(fleet) )
	return _db.insert_rows("fleet_slots", ships)

func save_fleet(fleet: FleetID) -> bool:
	return fleet != null \
	and save_fleet_ships(fleet) \
	and save_fleet_metadata(fleet)

func delete_ship(ship: ShipDataID) -> bool:
	return ship != null \
	and _db.delete_rows("ships", "id == %d" % ship.get_id() ) \
	and _db.delete_rows("fleet_slots", "ship_id == %d" % ship.get_id() ) \
	and _loaded_ships.erase(ship.get_id() )

func delete_fleet(fleet: FleetID) -> bool:
	return fleet != null \
	and _db.delete_rows("fleets", "id == %d" % fleet.get_id() ) \
	and _db.delete_rows("fleet_slots", "fleet_id == %d" % fleet.get_id() ) \
	and _loaded_fleets.erase(fleet.get_id() )

func _result_to_fleet(result: Dictionary) -> Fleet:
	return Fleet.new(result["name"], result["size"] )

func _result_to_ship(result: Dictionary) -> ShipData:
	var ship := ShipData.new(result["grid_width"], result["grid_height"] )
	var image_bytes = result.get("image")
	ship.name = result.name
	if image_bytes != null:
		ship.image = Image.create_from_data(result.image_width, result.image_height, ShipData.USE_MIPMAPS, PartImage.FORMAT, image_bytes)
	# TODO: Possible deferred deserialization to speed up load times
	var parts = result["parts"]
	parts = parts if parts != null else PackedByteArray()
	var error := ship.deserialize(parts, part_manager)
	var id: int = result["id"]
	if error & ShipData.PartError.INCORRECT_SIZE_BYTES:
		push_error("(ShipDatabase) Failed to load #%d: corrupted parts" % id)
	if error & ShipData.PartError.IS_NULL:
		push_error("(ShipDatabase) Failed to load #%d: part is null" % id)
	if error & ShipData.PartError.OUT_OF_BOUNDS:
		push_error("(ShipDatabase) Failed to load #%d: part is out of bounds" % id)
	if error & ShipData.PartError.OVERLAP:
		push_error("(ShipDatabase) Failed to load #%d: parts are overlapping" % id)
	return ship

func _fleet_to_query(fleet: Fleet) -> Dictionary:
	return {"name": fleet.name, "size": fleet.size() }

func _fleet_slot_to_query(slot: int, fleet: FleetID) -> Dictionary:
	return {"fleet_id": fleet.get_id(), "ship_id": fleet.fleet._ships[slot].get_id(), "slot": slot }

func _ship_to_query(ship: ShipData) -> Dictionary:
	var grid_size := ship.get_grid_rect().size
	var image_size := Vector2i.ZERO if ship.image == null else ship.image.get_size()
	var data := PackedByteArray() if ship.image == null else ship.image.get_data()
	return {
		"name": ship.name,
		"parts": ship.serialize(),
		"grid_width": grid_size.x,
		"grid_height": grid_size.y,
		"image_width": image_size.x,
		"image_height": image_size.y,
		"image": data
	}
