class_name ShipDatabase extends RefCounted

signal part_load_error(part_error: ShipData.PartError)

# If you change these, you will have to update all ships in the database
const PARTS_CSV_DELIMETER := ","
const SHIP_IMAGE_FORMAT := Image.FORMAT_RGBA8

# If you reformat these tables, you will have to update the entire database
const CREATE_SHIPS_TABLE := """
CREATE TABLE IF NOT EXISTS Ships (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	parts TEXT NOT NULL,
	grid_width INTEGER NOT NULL,
	grid_height INTEGER NOT NULL,
	image_width INTEGER NOT NULL,
	image_height INTEGER NOT NULL,
	image BLOB
);"""
const CREATE_FLEETS_TABLE := """
CREATE TABLE IF NOT EXISTS Fleets (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL
);"""
const CREATE_SHIP_FLEET_PAIRS_TABLE := """
CREATE TABLE IF NOT EXISTS ShipFleetPairs (
	ship_id INTEGER PRIMARY KEY,
	fleet_id INTEGER,
	slot TEXT NOT NULL,
	role INTEGER NOT NULL
);"""

var _db := SQLite.new()
var part_manager: PartManager = null

func load_file(path: String)->bool:
	_db.path = path
	var success := _db.open_db()
	_db.query(CREATE_SHIPS_TABLE)
	_db.query(CREATE_FLEETS_TABLE)
	_db.query(CREATE_SHIP_FLEET_PAIRS_TABLE)
	return success

func get_ships(limit: int)->Array:
	_db.query("SELECT * FROM Ships LIMIT %d;" % limit)
	return _db.query_result.map(_query_to_ship_id)

func get_fleets(limit: int)->Array:
	_db.query("SELECT * FROM Fleets LIMIT %d;" % limit)
	return _db.query_result.map(_query_to_fleet_id)

func create_ship(ship: ShipData)->ShipDataID:
	_db.insert_row("Ships", _ship_to_query(ship))
	return ShipDataID.wrap_ship(ship, _db.last_insert_rowid)

func create_fleet(fleet: Fleet)->FleetID:
	_db.insert_row("Fleets", {
		"name": fleet.name
	})
	return FleetID.wrap_fleet(fleet, _db.last_insert_rowid)

func sync_ship(ship_id: ShipDataID)->bool:
	_db.query("SELECT * FROM Ships WHERE Ships.id == %d LIMIT 1;" % ship_id.id)
	if _db.query_result.is_empty(): return false
	ship_id.ship_data = _query_to_ship(_db.query_result[0])
	return true

func sync_fleet_metadata(fleet_id: FleetID)->bool:
	_db.query("SELECT * FROM Fleets WHERE Fleets.id == %d LIMIT 1;" % fleet_id.id)
	if _db.query_result.is_empty(): return false
	fleet_id.fleet = _query_to_fleet(_db.query_result[0])
	return true

func sync_fleet_ships(fleet_id: FleetID)->bool:
	_db.query("SELECT Ships.id, Ships.name, Ships.parts, Ships.grid_width, Ships.grid_height, Ships.image_width, Ships.image_height FROM Ships, ShipFleetPairs WHERE ShipFleetPairs.fleet_id == %d AND Ships.id == ShipFleetPairs.ship_id;" % fleet_id.id)
	return _db.query_result.all(func(x): return fleet_id.fleet.set_ship(x.slot, x.slot_num, _query_to_ship_id(x)))

func sync_fleet(fleet_id: FleetID)->bool:
	return sync_fleet_metadata(fleet_id) and sync_fleet_ships(fleet_id)

func save_ship(ship_id: ShipDataID)->void:
	_db.update_rows("Ships", "id == %d" % ship_id.id, _ship_to_query(ship_id.ship_data))

func save_fleet_metadata(fleet_id: FleetID)->void:
	_db.update_rows("Fleets", "id == %d" % fleet_id.id, {
		"name": fleet_id.fleet.name
	})

func save_fleet_ships(fleet_id: FleetID)->void:
	_db.delete_rows("ShipFleetPairs", "fleet_id == %d" % fleet_id.id)
	var array := []
	for slot in fleet_id.fleet.slots:
		array.push_back(fleet_id.fleet.slots[slot].map(_ship_to_query.bind(fleet_id.id, slot)))
	_db.insert_rows("ShipFleetPairs", array)

func save_fleet(fleet_id: FleetID)->void:
	save_fleet_metadata(fleet_id)
	save_fleet_ships(fleet_id)

func delete_ship(ship_id: ShipDataID)->void:
	_db.delete_rows("Ships", "id == %d" % ship_id.id)
	_db.delete_rows("ShipFleetPairs", "ship_id == %d" % ship_id.id)

func delete_fleet(fleet_id: FleetID)->void:
	_db.delete_rows("Fleets", "id == %d" % fleet_id.id)
	_db.delete_rows("ShipFleetPairs", "fleet_id == %d" % fleet_id.id)

# Helper functions are below (you should not need to use these outside this class)

func _ship_to_query(ship: ShipData)->Dictionary:
	var size  := ship.get_grid_rect().size
	var image := ship.get_image()
	return {
		"name": ship.get_name(),
		"parts": ship.get_csv(),
		"grid_width": size.x,
		"grid_height": size.y,
		"image_width": image.get_size().x,
		"image_height": image.get_size().y,
		"image": image.get_data()
	}

func _csv_to_ship(csv: String, grid_width: int, grid_height: int)->ShipData:
	var ship := ShipData.create(grid_width, grid_height)
	for line in csv.split("\n"):
		var error := ship.add_part_csv_line(line.split(PARTS_CSV_DELIMETER), part_manager)
		if error != ShipData.PartError.OKAY:
			part_load_error.emit(error)
	return ship

func _query_to_fleet(result: Dictionary)->Fleet:
	var fleet := Fleet.new()
	fleet.name = result.name
	return fleet

func _query_to_ship(result: Dictionary)->ShipData:
	var ship := _csv_to_ship(result.parts, result.grid_width, result.grid_height)
	var blob = result.image
	if blob != null:
		var width: int = result.image_width
		var height: int = result.image_height
		var image := Image.create_from_data(width, height, true, SHIP_IMAGE_FORMAT, blob)
		ship.set_image(image)
	ship.set_name(result.name)
	return ship

func _query_to_fleet_id(result: Dictionary)->FleetID:
	return FleetID.wrap_fleet(_query_to_fleet(result), result.id)

func _query_to_ship_id(result: Dictionary)->ShipDataID:
	return ShipDataID.wrap_ship(_query_to_ship(result), result.id)
