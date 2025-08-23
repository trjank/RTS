class_name ShipDB extends RefCounted

var db: SQLite

func load_db(path: String = "user://shipdb.db")->void:
	db = SQLite.new()
	db.path = path
	db.open_db()

func get_ship(ship_id: int)->Array[Dictionary]:
	db.query_with_bindings("SELECT * FROM Ships WHERE Ships.id == ?;", [ship_id])
	return db.query_result

func get_ships(limit: int)->Array[Dictionary]:
	db.query_with_bindings("SELECT * FROM Ships LIMIT ?", [limit])
	return db.query_result

func get_fleet(fleet_id: int)->Array[Dictionary]:
	db.query_with_bindings("SELECT * FROM Ships WHERE Ships.id == ?;", [fleet_id])
	return db.query_result

func get_fleets()->Array[Dictionary]:
	db.query("SELECT * FROM Fleets;")
	return db.query_result

func get_ships_in_fleet(fleet_id: int)->Array[Dictionary]:
	db.query_with_bindings("SELECT Ships.id, Ships.stats, Ships.name FROM Ships, ShipFleet WHERE Ships.id == ShipFleet.shipid AND ShipFleet.fleetid == ?;", [fleet_id])
	return db.query_result

func add_ship_to_fleet(fleet_id: int, ship_id: int)->bool:
	return db.query_with_bindings("INSERT INTO ShipFleet (shipid, fleetid) VALUES(?,?);", [ship_id,fleet_id])

func create_ship(ship_name: String, ship_stats)->Array[Dictionary]:
	db.query_with_bindings("INSERT INTO Ships (name,stats) VALUES(?,?) RETURNING *;", [ship_name,ship_stats])
	return db.query_result

func update_ship_stats(ship_id: int, stats)->void:
	db.query_with_bindings("UPDATE Ships SET stats=? WHERE id=?;",[stats,ship_id])

func create_fleet(fleet_name: String):
	db.query_with_bindings("INSERT INTO Fleets (name) VALUES(?);", [fleet_name])
	return db.query_result

func remove_fleet_and_ships(fleet_id: int)->bool:
	if not delete_fleet(fleet_id):
		return false
	return db.query_with_bindings("DELETE FROM ShipFleet WHERE fleetid=?;", [fleet_id])

func delete_fleet(fleet_id: int)->bool:
	return db.query_with_bindings("DELETE FROM Fleets WHERE id=?;", [fleet_id])

func rename_fleet(fleet_id: int, new_name: String)->bool:
	return db.query_with_bindings("UPDATE Fleets SET name=? WHERE id=?;", [new_name,fleet_id])
