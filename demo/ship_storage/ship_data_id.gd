class_name ShipDataID extends RefCounted

signal ship_changed(new_ship_data: ShipData)

var ship_data: ShipData:
	set = set_ship_data

var _id: int
var _db: ShipDatabase

func _init(init_ship_data: ShipData, init_db: ShipDatabase, init_id: int) -> void:
	ship_data = init_ship_data
	_id = init_id
	_db = init_db

func get_id() -> int:
	return _id

func get_db() -> ShipDatabase:
	return _db

func set_ship_data(new_ship_data: ShipData) -> void:
	if new_ship_data == null:
		return push_error("ShipDataID.ship_data is NULL")
	if new_ship_data == ship_data:
		return
	ship_data = new_ship_data
	ship_changed.emit(ship_data)

func sync() -> bool:
	return _db.sync_ship(self)

func save() -> bool:
	return _db.save_ship(self)
