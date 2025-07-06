class_name DB extends Node

var database:SQLite
var db_path = "user://shipdb.db"
#i just manually made a db LOL



func _init():
	database = SQLite.new()
	database.path = db_path
	database.open_db()



func get_ship(ship_id):
		var success = database.query_with_bindings("SELECT * FROM Ships WHERE Ships.id == ?;",[ship_id])
		if success:
			return database.query_result
		return []

func get_ships(limit):
	var success = database.query_with_bindings("SELECT * FROM Ships LIMIT ?",[limit])
	if success:
		return database.query_result
	return []

func get_fleet(fleet_id):
	if database.query_with_bindings("SELECT * FROM Ships WHERE Ships.id == ?;",[fleet_id]):
		return database.query_result
	return []

func get_ships_in_fleet(fleet_id):
	if database.query_with_bindings("SELECT Ships.id, Ships.stats, Ships.name FROM Ships, ShipFleet WHERE Ships.id == ShipFleet.shipid AND ShipFleet.fleetid == ?;",[fleet_id]):
		return database.query_result
	return []

func add_ship_to_fleet(fleet_id,ship_id):
	var _success = database.query_with_bindings("INSERT INTO ShipFleet (shipid, fleetid) VALUES(?,?);",[ship_id,fleet_id])

	

func create_ship(ship_name,ship_stats):
	var _success = database.query_with_bindings("INSERT INTO Ships (name,stats) VALUES(?,?) RETURNING *;",[ship_name,ship_stats])
	if _success:
		return database.query_result
	return []

func update_ship_stats(ship_id, stats):
	var _success = database.query_with_bindings("UPDATE Ships SET stats=? WHERE id=?;",[stats,ship_id])




func create_fleet(fleet_name):
	database.insert_row("fleets",{"name":fleet_name})
	
