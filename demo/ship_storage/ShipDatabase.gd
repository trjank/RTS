class_name ShipDatabase extends RefCounted

# If you change this, you will have to update all ships in the database
const PARTS_CSV_DELIMETER := ","

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
	return _db.query_result.map(query_to_ship)

func get_fleets(limit: int)->Array:
	_db.query("SELECT * FROM Fleets LIMIT %d;" % limit)
	return _db.query_result.map(query_to_fleet_id)

func add_ship_to_fleet(ship_id: int, fleet_id: int, slot: int, role: String)->bool:
	return _db.insert_row("ShipFleetPairs", {
		"ship_id": ship_id,
		"fleet_id": fleet_id,
		"slot": slot,
		"role": role
	})

func create_ship(ship: ShipData)->ShipDataID:
	var grid_rect := ship.get_grid_rect()
	var image := ship.get_image()
	_db.insert_row("Ships", {
		"name": ship.get_name(),
		"parts": ship.get_csv(),
		"grid_width": grid_rect.size.x,
		"grid_height": grid_rect.size.y,
		"image_width": image.get_size().x,
		"image_height": image.get_size().y,
		"image": image.get_data()
	})
	return ShipDataID.wrap_ship(ship, _db.last_insert_rowid)

func create_fleet(fleet: Fleet)->FleetID:
	_db.insert_row("Fleets", {
		"name": fleet.name
	})
	return FleetID.wrap_fleet(fleet, _db.last_insert_rowid)

func get_ships_in_fleet(fleet_id: int)->Array:
	_db.query("SELECT Ships.id, Ships.name, Ships.parts, Ships.grid_width, Ships.grid_height, Ships.image_width, Ships.image_height FROM Ships, ShipFleetPairs WHERE ShipFleetPairs.fleet_id == %d AND Ships.id == ShipFleetPairs.ship_id;" % fleet_id)
	return _db.query_result.map(query_to_ship_id)

func sync_ship(ship_id: ShipDataID)->bool:
	_db.query("SELECT * FROM Ships WHERE Ships.id == %d LIMIT 1;" % ship_id)
	if _db.query_result.is_empty(): return false
	ship_id.ship_data = query_to_ship(_db.query_result[0])
	return true

func sync_fleet(fleet_id: FleetID)->bool:
	_db.query("SELECT * FROM Fleets WHERE Fleets.id == %d LIMIT 1;" % fleet_id)
	if _db.query_result.is_empty(): return false
	fleet_id.fleet = query_to_fleet_id(_db.query_result[0]).fleet
	return true

func save_ship(ship_id: ShipDataID)->void:
	var ship := ship_id.ship_data
	var size := ship.get_grid_rect().size
	_db.update_rows("Ships", "id == %d" % ship_id.id, {
		"name": ship.get_name(),
		"parts": ship.get_csv(),
		"grid_width": size.x,
		"grid_height": size.y,
		"image": ship.get_image()
	})

func save_fleet(fleet_id: FleetID)->void:
	_db.update_rows("Fleets", "id == %d" % fleet_id.id, {
		"name": fleet_id.fleet.name
	})

func delete_ship(ship_id: ShipDataID)->void:
	_db.delete_rows("Ships", "id == %d" % ship_id.id)
	_db.delete_rows("ShipFleetPairs", "ship_id == %d" % ship_id.id)

func delete_fleet(fleet_id: FleetID)->void:
	_db.delete_rows("Fleets", "id == %d" % fleet_id.id)
	_db.delete_rows("ShipFleetPairs", "fleet_id == %d" % fleet_id.id)

func csv_to_ship(csv: String, grid_width: int, grid_height: int)->ShipData:
	var ship := ShipData.create(grid_width, grid_height)
	for line in csv.split("\n"):
		ship.add_part_csv_line(line.split(PARTS_CSV_DELIMETER), part_manager)
	return ship

func query_to_fleet(result: Dictionary)->Fleet:
	var fleet := Fleet.new()
	fleet.name = result.get("name", "")
	return fleet

func query_to_fleet_id(result: Dictionary)->FleetID:
	var fleet := query_to_fleet(result)
	var id: int = result.get("id", -1)
	return FleetID.wrap_fleet(fleet, id)

func query_to_ship(result: Dictionary)->ShipData:
	var ship := csv_to_ship(result["parts"], result["grid_width"], result["grid_height"])
	var blob = result["image"]
	if blob != null:
		var width: int = result["image_width"]
		var height: int = result["image_height"]
		var image := Image.create_from_data(width, height, true, Image.FORMAT_RGBA8, blob)
		ship.set_image(image)
	ship.set_name(result["name"])
	return ship

func query_to_ship_id(result: Dictionary)->ShipDataID:
	var ship := query_to_ship(result)
	var id: int = result.get("id", -1)
	return ShipDataID.wrap_ship(ship, id)
