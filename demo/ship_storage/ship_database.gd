class_name ShipDatabase extends RefCounted

const PARTS_CSV_DELIMETER := ","
const SHIP_IMAGE_FORMAT := Image.FORMAT_RGBA8
const SHIP_IMAGE_USE_MIPMAPS := false
const DEBUG_PRINT_PART_ERRORS := true

const CREATE_SHIPS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS ships (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	grid_width INTEGER NOT NULL,
	grid_height INTEGER NOT NULL,
	image_width INTEGER NOT NULL,
	image_height INTEGER NOT NULL,
	parts BLOB NOT NULL,
	image BLOB
);"""
const CREATE_FLEETS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS fleets (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	size INTEGER NOT NULL
);"""
const CREATE_SHIP_FLEET_PAIRS_TABLE_QUERY := """
CREATE TABLE IF NOT EXISTS ship_fleet_pairs (
	ship_id INTEGER PRIMARY KEY,
	fleet_id INTEGER,
	slot TEXT NOT NULL,
	role INTEGER NOT NULL
);"""

var db := SQLite.new()
var part_manager: PartManager

func load_file(path: String) -> bool:
	db.path = path
	var success := db.open_db() \
	and db.query(CREATE_SHIPS_TABLE_QUERY) \
	and db.query(CREATE_FLEETS_TABLE_QUERY) \
	and db.query(CREATE_SHIP_FLEET_PAIRS_TABLE_QUERY)
	return success

func get_ships(limit: int) -> Array:
	db.query("SELECT * FROM ships LIMIT %d;" % limit)
	return db.query_result.map(query_to_ship_id)

func get_fleets(limit: int) -> Array:
	db.query("SELECT * FROM fleets LIMIT %d;" % limit)
	return db.query_result.map(query_to_fleet_id)

func get_ship(ship_id: int) -> ShipDataID:
	#db.query("SELECT * FROM ships WHERE ships.id == %d LIMIT 1;" % ship_id.id)
	var ships := db.select_rows("ships", "id == %d LIMIT 1" % ship_id, ["*"])
	return null if ships.is_empty() else query_to_ship_id(ships[0])

func get_fleet(fleet_id: int) -> FleetID:
	#db.query("SELECT * FROM fleets WHERE fleets.id == %d LIMIT 1;" % fleet_id.id)
	var fleets := db.select_rows("fleets", "id == %d LIMIT 1" % fleet_id, ["*"])
	return null if fleets.is_empty() else query_to_fleet_id(fleets[0])

func create_ship(ship: ShipData) -> ShipDataID:
	assert(ship != null)
	db.insert_row("ships", ship_to_query(ship))
	return ShipDataID.new(ship, db.last_insert_rowid)

func create_fleet(fleet: Fleet) -> FleetID:
	assert(fleet != null)
	db.insert_row("fleets", {"name": fleet.name})
	return FleetID.new(fleet, db.last_insert_rowid)

func sync_ship(ship_id: ShipDataID) -> bool:
	var db_ship := get_ship(ship_id.id)
	if db_ship == null:
		return false
	ship_id.ship_data = db_ship.ship_data
	return true

func sync_fleet_metadata(fleet_id: FleetID) -> bool:
	var db_fleet := get_fleet(fleet_id.id)
	if db_fleet == null:
		return false
	fleet_id.fleet.name = db_fleet.fleet.name
	return true

func sync_fleet_ships(fleet_id: FleetID) -> bool:
	db.query("SELECT ships.id, ships.name, ships.parts, ships.grid_width, ships.grid_height, ships.image_width, ships.image_height FROM ships, ship_fleet_pairs WHERE ship_fleet_pairs.fleet_id == %d AND ships.id == ship_fleet_pairs.ship_id;" % fleet_id.id)
	return db.query_result.all(func (ship: Dictionary) -> bool:
		return fleet_id.fleet.set_ship(ship.slot, ship.slot_num, query_to_ship_id(ship))
	)

func sync_fleet(fleet: FleetID) -> bool:
	return sync_fleet_metadata(fleet) and sync_fleet_ships(fleet)

func save_ship(ship: ShipDataID) -> void:
	assert(ship != null)
	db.update_rows("ships", "id == %d" % ship.id, ship_to_query(ship.ship_data))

func save_fleet_metadata(fleet: FleetID) -> void:
	assert(fleet != null)
	db.update_rows("fleets", "id == %d" % fleet.id, fleet_to_query(fleet.fleet))

func save_fleet_ships(fleet: FleetID) -> void:
	assert(fleet != null)
	db.delete_rows("ship_fleet_pairs", "fleet_id == %d" % fleet.id)
	var array := []
	for slot in fleet.fleet.slots:
		array.push_back(fleet.fleet.slots[slot].map(ship_to_query.bind(fleet.id, slot)))
	db.insert_rows("ship_fleet_pairs", array)

func save_fleet(fleet: FleetID) -> void:
	assert(fleet != null)
	save_fleet_metadata(fleet)
	save_fleet_ships(fleet)

func delete_ship(ship: ShipDataID) -> void:
	assert(ship != null)
	db.delete_rows("ships", "id == %d" % ship.id)
	db.delete_rows("ship_fleet_pairs", "ship_id == %d" % ship.id)

func delete_fleet(fleet: FleetID) -> void:
	assert(fleet != null)
	db.delete_rows("fleets", "id == %d" % fleet.id)
	db.delete_rows("ship_fleet_pairs", "fleet_id == %d" % fleet.id)

func fleet_to_query(fleet: Fleet) -> Dictionary:
	return {
		"name": fleet.name,
		"size": fleet.ships.size()
	}

func ship_to_query(ship: ShipData) -> Dictionary:
	return {
		"name": ship.name,
		"parts": ship.serialize(),
		"grid_width": ship.grid_rect.size.x,
		"grid_height": ship.grid_rect.size.y,
		"image_width": ship.image.get_size().x,
		"image_height": ship.image.get_size().y,
		"image": ship.image.get_data()
	}

func query_to_fleet_id(result: Dictionary) -> FleetID:
	return FleetID.new(query_to_fleet(result), result.id)

func query_to_fleet(result: Dictionary) -> Fleet:
	return Fleet.new(result.get("name", Fleet.DEFAULT_NAME))

func query_to_ship_id(result: Dictionary) -> ShipDataID:
	return ShipDataID.new(query_to_ship(result), result.id)

func query_to_ship(result: Dictionary) -> ShipData:
	var ship := ShipData.new(result.grid_width, result.grid_height)
	var error := ship.deserialize(result.parts, part_manager)
	var blob = result.get("image")
	ship.name = result.name
	if DEBUG_PRINT_PART_ERRORS and error != ShipData.PartError.OK:
		print("[DEBUG] Database ship part error: ", ShipData.PartError.find_key(error))
	if blob is String:
		ship.image = Image.create_from_data(result.image_width, result.image_height, SHIP_IMAGE_USE_MIPMAPS, SHIP_IMAGE_FORMAT, blob)
	return ship
