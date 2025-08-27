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

func get_fleets():
	if database.query("SELECT * FROM Fleets;"):
		return database.query_result
	return []

func get_ships_in_fleet(fleet_id):
	if database.query_with_bindings("SELECT Ships.id, Ships.stats, Ships.name FROM Ships, ShipFleet WHERE Ships.id == ShipFleet.shipid AND ShipFleet.fleetid == ?;",[fleet_id]):
		return database.query_result
	return []

func add_ship_to_fleet(fleet_id,ship_id):
	var _success = database.query_with_bindings("INSERT INTO ShipFleet (shipid, fleetid) VALUES(?,?);",[ship_id,fleet_id])
	print(_success)
	

func create_ship(ship_name,ship_stats):
	var _success = database.query_with_bindings("INSERT INTO Ships (name,stats) VALUES(?,?) RETURNING *;",[ship_name,ship_stats])
	if _success:
		return database.query_result
	return []

func update_ship_stats(ship_id, stats):
	var _success = database.query_with_bindings("UPDATE Ships SET stats=? WHERE id=?;",[stats,ship_id])




func create_fleet(fleet_name):
	var _success = database.query_with_bindings("INSERT INTO Fleets (name) VALUES(?);",[fleet_name])
	if _success:
		return database.query_result
	return []	


func remove_fleet_and_ships(fleet_id):
	if !delete_fleet(fleet_id):
		return false
	var _success = database.query_with_bindings("DELETE FROM ShipFleet WHERE fleetid=?;",[fleet_id])
	if _success:
		return true
	return false

func delete_fleet(fleet_id):
	var _success = database.query_with_bindings("DELETE FROM Fleets WHERE id=?;",[fleet_id])
	if _success:
		return true
	return false


func rename_fleet(fleet_id, new_name):
	var _success = database.query_with_bindings("UPDATE Fleets SET name=? WHERE id=?;",[new_name,fleet_id])
	if _success:
		return true
	return false	
