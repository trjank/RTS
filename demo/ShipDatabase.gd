class_name ShipDatabase extends RefCounted

enum Role {
	REGULAR_SHIP,
	CAPITAL_SHIP,
	TURRET
}

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
	slot INTEGER NOT NULL,
	role INTEGER NOT NULL
);"""

var _db := SQLite.new()
var part_manager: PartManager = null

func csv_to_ship(csv: String, grid_width: int, grid_height: int)->ShipData:
	var ship := ShipData.create(grid_width, grid_height)
	for line in csv.split("\n"):
		ship.add_part_csv_line(line.split(PARTS_CSV_DELIMETER), part_manager)
	return ship

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

func save_to(path: String)->bool:
	return _db.backup_to(path)

func load_from(path: String)->bool:
	_db.path = path
	var success := _db.open_db()
	_db.query(CREATE_SHIPS_TABLE)
	_db.query(CREATE_FLEETS_TABLE)
	_db.query(CREATE_SHIP_FLEET_PAIRS_TABLE)
	return success

func get_ship(ship_id: int)->ShipData:
	_db.query("SELECT * FROM Ships WHERE Ships.id == %d LIMIT 1;" % ship_id)
	var not_found := _db.query_result.is_empty()
	return null if not_found else query_to_ship(_db.query_result[0])

func get_ships(limit: int)->Array:
	_db.query("SELECT * FROM Ships LIMIT %d;" % limit)
	return _db.query_result.map(query_to_ship)

func get_fleet(fleet_id: int)->Dictionary:
	print("test->",_db.query("SELECT * FROM Fleets WHERE Fleets.id == %d LIMIT 1;" % fleet_id))
	var not_found := _db.query_result.is_empty()
	return {} if not_found else _db.query_result[0]

func get_fleets(limit: int)->Array[Dictionary]:
	_db.query("SELECT * FROM Fleets LIMIT %d;" % limit)
	return _db.query_result

func get_ships_in_fleet(fleet_id: int)->Array[Dictionary]:
	_db.query("SELECT Ships.id, Ships.name, Ships.parts, Ships.grid_width, Ships.grid_height FROM Ships, ShipFleetPairs WHERE ShipFleetPairs.fleet_id == %d AND Ships.id == ShipFleetPairs.ship_id;" % fleet_id)
	return _db.query_result

func add_ship_to_fleet(ship_id: int, fleet_id: int, slot: int, role := Role.REGULAR_SHIP)->bool:
	return _db.insert_row("ShipFleetPairs", {
		"ship_id": ship_id,
		"fleet_id": fleet_id,
		"slot": slot,
		"role": int(role)
	})

func create_ship(ship: ShipData)->int:
	var grid_rect := ship.get_grid_rect()
	var image     := ship.get_image()
	_db.insert_row("Ships", {
		"name": ship.get_name(),
		"parts": ship.get_csv(),
		"grid_width": grid_rect.size.x,
		"grid_height": grid_rect.size.y,
		"image_width": image.get_size().x,
		"image_height": image.get_size().y,
		"image": image.get_data()
	})
	return _db.last_insert_rowid

func update_ship(ship_id: int, ship: ShipData)->bool:
	var grid_rect := ship.get_grid_rect()
	# Returns false if the ship already exists
	return _db.update_rows("Ships", "id == %d" % ship_id, {
		"name": ship.get_name(),
		"parts": ship.get_csv(),
		"grid_width": grid_rect.size.x,
		"grid_height": grid_rect.size.y,
		"image": ship.get_image()
	})

func create_fleet(fleet_name: String)->int:
	_db.insert_row("Fleets", {"name": fleet_name})
	return _db.last_insert_rowid

func delete_fleet(fleet_id: int)->void:
	_db.delete_rows("Fleets", "id == %d" % fleet_id)
	_db.delete_rows("ShipFleetPairs", "fleet_id == %d" % fleet_id)

func rename_fleet(fleet_id: int, new_name: String)->bool:
	return _db.update_rows("Fleets", "id == %d" % fleet_id, {"name": new_name})
