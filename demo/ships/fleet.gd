class_name Fleet extends RefCounted

signal ui_update
signal resized(new_size: int)
signal renamed(new_name: String)
signal ship_changed(new_ship: ShipData, slot: int)

const MIN_SIZE := 1
const MAX_SIZE := 20
const MAX_NAME_LENGTH := 50
const CAPITAL_SHIP_SLOT := 0

var size: int:
	get = get_size,
	set = set_size
var name := "":
	set = set_name

var _ships: Array[ShipData] = [null]
var _db: ShipDatabase
var _id := -1

func get_size() -> int:
	return _ships.size()

func get_db() -> ShipDatabase:
	return _db

func get_id() -> int:
	return _id

func sync_metadata() -> bool:
	return _db != null and _db.sync_fleet_metadata(self)

func sync_ships() -> bool:
	return _db != null and _db.sync_fleet_ships(self)

func sync() -> bool:
	return _db != null and _db.sync_fleet(self)

func save_metadata() -> bool:
	return _db != null and _db.save_fleet_metadata(self)

func save_ships() -> bool:
	return _db != null and _db.save_fleet_ships(self)

func save() -> bool:
	return _db != null and _db.save_fleet(self)

func has_slot(slot: int) -> bool:
	return 0 <= slot and slot < _ships.size()

func has_ship(ship: ShipData) -> bool:
	return ship in _ships

func has_ship_in_slot(slot: int) -> bool:
	return _ships[slot] != null

func get_ship(slot: int) -> ShipData:
	return _ships[slot] if has_slot(slot) else null

func set_ship(slot: int, ship: ShipData) -> bool:
	if not has_slot(slot) or ship == _ships[slot]:
		return false
	# NOTE:    ^^^^^ This allows for one-line set and save
	# (var success := set_ship(..) and save_ships() )
	_ships[slot] = ship
	ship_changed.emit(ship, slot)
	return true

func set_name(new_name: String) -> bool:
	new_name = new_name.substr(0, MAX_NAME_LENGTH)
	if name == new_name:
		return false
	# NOTE:    ^^^^^ This allows for one-line set and save
	# (var success := set_name(..) and save_metadata() )
	name = new_name
	renamed.emit(name)
	ui_update.emit()
	return true

func set_size(new_size: int) -> bool:
	new_size = clampi(new_size, MIN_SIZE, MAX_SIZE)
	if size == new_size:
		return false
	# NOTE:    ^^^^^ This allows for one-line set and save
	# (var success := set_size(..) and save_metadata() )
	_ships.resize(new_size)
	resized.emit(new_size)
	return true

func for_each_ship(f: Callable) -> void:
	for slot in _ships.size():
		f.call(_ships[slot], slot)
	# NOTE: Slot is provided ^^^^ (make sure f takes two parameters)
