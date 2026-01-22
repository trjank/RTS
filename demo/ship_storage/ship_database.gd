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
	fleet_id INTEGER,
	ship_id INTEGER,
	slot INTEGER NOT NULL,
	PRIMARY KEY (fleet_id, slot)
);
"""
const ALL_COLUMNS := ["*"]

var part_manager: PartManager

# NOTE: Ships and fleets are kept unique to prevent bugs and wasteful copying
var _loaded_ships: Dictionary[int, ShipData] = {}
var _loaded_fleets: Dictionary[int, Fleet] = {}
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

func _load_ship(result: Dictionary) -> ShipData:
	var ship := ShipData.new()
	ship._db = self
	ship._id = result["id"]
	ship.grid_size = Vector2i(result["grid_width"], result["grid_height"] )
	_parse_ship_from_result(ship, result)
	_loaded_ships[ship._id] = ship
	return ship

func _load_fleet(result: Dictionary) -> Fleet:
	var fleet := Fleet.new()
	fleet._db = self
	fleet._id = result["id"]
	fleet.size = result["size"]
	fleet.name = result["name"]
	sync_fleet_ships(fleet)
	_loaded_fleets[fleet._id] = fleet
	return fleet

func get_ship(ship_id: int) -> ShipData:
	if ship_id in _loaded_ships:
		return _loaded_ships[ship_id]
	var results := _db.select_rows("ships", "id == %d" % ship_id, ALL_COLUMNS)
	return null if results.is_empty() else _load_ship(results[0] )

func get_fleet(fleet_id: int) -> Fleet:
	if fleet_id in _loaded_fleets:
		return _loaded_fleets[fleet_id]
	var results := _db.select_rows("fleets", "id == %d" % fleet_id, ALL_COLUMNS)
	return null if results.is_empty() else _load_fleet(results[0] )

func create_ship(ship: ShipData) -> bool:
	if ship == null or ship._db != null or not _db.insert_row("ships", _ship_to_query(ship) ):
		return false
	ship._db = self
	ship._id = _db.last_insert_rowid
	return true

func create_fleet(fleet: Fleet) -> bool:
	if fleet == null or fleet._db != null or not _db.insert_row("fleets", _fleet_to_query(fleet) ):
		return false
	fleet._db = self
	fleet._id = _db.last_insert_rowid
	return true

func sync_ship(ship: ShipData) -> bool:
	if ship == null or not ship.get_id() in _loaded_ships:
		return false
	var results := _db.select_rows("ships", "ship_id == %d" % ship.get_id(), ALL_COLUMNS)
	_parse_ship_from_result(ship, results[0] )
	return true

func sync_fleet_metadata(fleet: Fleet) -> bool:
	if fleet == null or not fleet.get_id() in _loaded_fleets:
		return false
	var results := _db.select_rows("fleets", "fleet_id == %d" % fleet.get_id(), ALL_COLUMNS)
	var result: Dictionary = results[0]
	fleet.fleet.name = result["name"]
	return fleet.fleet.ships.resize(result["size"] ) == OK

func sync_fleet_ships(fleet: Fleet) -> bool:
	var results := _db.select_rows("fleet_slots", "fleet_id == %d" % fleet.get_id(), ALL_COLUMNS)
	for result in results:
		var ship := get_ship(result["ship_id"] )
		fleet.set_ship(result["slot"], ship)
	return fleet.size == results.size()

func sync_fleet(fleet: Fleet) -> bool:
	return sync_fleet_metadata(fleet) and sync_fleet_ships(fleet)

func save_ship(ship: ShipData) -> bool:
	return ship != null and _db.update_rows("ships", "id == %d" % ship.get_id(), _ship_to_query(ship) )

func save_fleet_metadata(fleet: Fleet) -> bool:
	return fleet != null and _db.update_rows("fleets", "id == %d" % fleet.get_id(), _fleet_to_query(fleet) )

func save_fleet_ships(fleet: Fleet) -> bool:
	if fleet == null:
		return false
	_db.delete_rows("fleet_slots", "fleet_id == %d" % fleet.get_id() )
	var ships := range(fleet.size).filter(fleet.has_ship_in_slot).map(_fleet_slot_to_query.bind(fleet) )
	return _db.insert_rows("fleet_slots", ships)

func save_fleet(fleet: Fleet) -> bool:
	return fleet != null and save_fleet_ships(fleet) and save_fleet_metadata(fleet)

func delete_ship(ship: ShipData) -> bool:
	return ship != null \
	and _db.delete_rows("ships", "id == %d" % ship.get_id() ) \
	and _db.delete_rows("fleet_slots", "ship_id == %d" % ship.get_id() ) \
	and _loaded_ships.erase(ship.get_id() )

func delete_fleet(fleet: Fleet) -> bool:
	return fleet != null \
	and _db.delete_rows("fleets", "id == %d" % fleet.get_id() ) \
	and _db.delete_rows("fleet_slots", "fleet_id == %d" % fleet.get_id() ) \
	and _loaded_fleets.erase(fleet.get_id() )

func _parse_ship_from_result(ship: ShipData, result: Dictionary) -> void:
	var image_bytes = result["image"]
	var parts = result["parts"]
	var error := ship.deserialize(parts if parts != null else PackedByteArray(), part_manager)
	handle_deserialization_error(error, result["id"] )
	ship.calculate_stats()
	ship.name = result["name"]
	if image_bytes == null:
		ship._image = null
		ship._texture = null
	else:
		ship._image = Image.create_from_data(result.image_width, result.image_height, ShipData.USE_MIPMAPS, PartImage.FORMAT, image_bytes)
		ship._texture = ImageTexture.create_from_image(ship._image)

func handle_deserialization_error(error: int, ship_id: int) -> void:
	if error & ShipData.PartError.INCORRECT_SIZE_BYTES:
		push_error("(ShipDatabase) Failed to load #%d: corrupted parts" % ship_id)
	if error & ShipData.PartError.IS_NULL:
		push_error("(ShipDatabase) Failed to load #%d: part is null" % ship_id)
	if error & ShipData.PartError.OUT_OF_BOUNDS:
		push_error("(ShipDatabase) Failed to load #%d: part is out of bounds" % ship_id)
	if error & ShipData.PartError.OVERLAP:
		push_error("(ShipDatabase) Failed to load #%d: parts are overlapping" % ship_id)

func _fleet_to_query(fleet: Fleet) -> Dictionary:
	return { "name": fleet.name,"size": fleet.size }

func _fleet_slot_to_query(slot: int, fleet: Fleet) -> Dictionary:
	return { "fleet_id": fleet.get_id(), "ship_id": fleet._ships[slot].get_id(), "slot": slot}

func _ship_to_query(ship: ShipData) -> Dictionary:
	var image_size := ship.get_image().get_size() if ship.get_image() != null else Vector2i.ZERO
	var image_data := ship.get_image().get_data() if ship.get_image() != null else PackedByteArray()
	return {
		"name": ship.name,
		"parts": ship.serialize(),
		"grid_width": ship.grid_size.x,
		"grid_height": ship.grid_size.y,
		"image_width": image_size.x,
		"image_height": image_size.y,
		"image": image_data
	}
