class_name FleetID extends RefCounted

signal fleet_changed(new_fleet: Fleet)

var fleet: Fleet:
	set = set_fleet

var _id: int
var _db: ShipDatabase

func _init(init_fleet: Fleet, init_db: ShipDatabase, init_id: int) -> void:
	fleet = init_fleet
	_id = init_id
	_db = init_db

func get_id() -> int:
	return _id

func get_db() -> ShipDatabase:
	return _db

func set_fleet(new_fleet: Fleet) -> void:
	if new_fleet == null:
		return push_error("FleetID.fleet is NULL")
	if new_fleet == fleet:
		return
	fleet = new_fleet
	fleet_changed.emit(fleet)

func sync_metadata() -> bool:
	return _db.sync_fleet_metadata(self)

func sync_ships() -> bool:
	return _db.sync_fleet_ships(self)

func sync() -> bool:
	return _db.sync_fleet(self)

func save_metadata() -> bool:
	return _db.save_fleet_metadata(self)

func save_ships() -> bool:
	return _db.save_fleet_ships(self)

func save() -> bool:
	return _db.save_fleet(self)
