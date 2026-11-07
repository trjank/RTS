class_name ShipManager extends RefCounted

signal ship_created(ship: ShipData)
signal ship_deleted(ship: ShipData)
signal fleet_created(fleet: Fleet)
signal fleet_deleted(fleet: Fleet)

# Keep ID_BITS below 64 so ShipData and FLeet uids fit in a single integer
# (See ShipData and Fleet for how unique global ids are constructed)
const ID_BITS := 16
const MIN_ID := 0
const MAX_ID := 2 ** ID_BITS - 1

static var _registry: Dictionary[int, ShipManager] = {}

var _id: int
var _last_ship_insert_id := -1
var _last_fleet_insert_id := -1
var _loaded_ships: Dictionary[int, ShipData] = {}
var _loaded_fleets: Dictionary[int, Fleet] = {}

static func from_id(id: int) -> ShipManager:
	return _registry.get(id)

func _init(const_id: int) -> void:
	_id = clampi(const_id, MIN_ID, MAX_ID)

func get_id() -> int:
	return _id

## Exposes the database globally (must have a unique id to work)
func register() -> bool:
	return not _id in _registry and _registry.set(_id, self)

func owns_ship(ship: ShipData) -> bool:
	return ship != null and ship.db == self

func owns_fleet(fleet: Fleet) -> bool:
	return fleet != null and fleet.db == self

func clear() -> void:
	_loaded_ships.clear()
	_loaded_fleets.clear()

func delete() -> void:
	clear()

func count_loaded_ships() -> int:
	return _loaded_ships.size()

func count_loaded_fleets() -> int:
	return _loaded_fleets.size()

func load_ships(_limit: int) -> Array:
	return _loaded_ships.values()

func load_fleets(_limit: int) -> Array:
	return _loaded_fleets.values()

func get_loaded_ships() -> Array:
	return _loaded_ships.values()

func get_loaded_fleets() -> Array:
	return _loaded_fleets.values()

func get_ship(ship_id: int) -> ShipData:
	return _loaded_ships.get(ship_id)

func get_fleet(fleet_id: int) -> Fleet:
	return _loaded_fleets.get(fleet_id)

func sync_ship(ship: ShipData) -> bool:
	return owns_ship(ship)

## NOTE: This does not automatically update ship.saved (use ship.save() instead for that)
func save_ship(ship: ShipData) -> bool:
	return owns_ship(ship)

## NOTE: This does not automatically update fleet.saved (use fleet.save() instead for that)
func save_fleet(fleet: Fleet) -> bool:
	return owns_fleet(fleet)

func sync_fleet(fleet: Fleet) -> bool:
	return owns_fleet(fleet)

func sync_fleet_metadata(fleet: Fleet) -> bool:
	return owns_fleet(fleet)

func sync_fleet_ships(fleet: Fleet) -> bool:
	return owns_fleet(fleet)

func save_fleet_metadata(fleet: Fleet) -> bool:
	return owns_fleet(fleet)

func save_fleet_ships(fleet: Fleet) -> bool:
	return owns_fleet(fleet)

func create_ship(ship: ShipData) -> bool:
	if ship == null or ship.db != null:
		return false
	ship.db = self
	ship.id = _last_ship_insert_id + 1
	_last_fleet_insert_id = ship.id
	_loaded_ships[ship.id] = ship
	ship_created.emit(ship)
	return true

func create_fleet(fleet: Fleet) -> bool:
	if fleet == null or fleet.db != null:
		return false
	fleet.db = self
	fleet.id = _last_fleet_insert_id + 1
	_last_fleet_insert_id = fleet.id
	_loaded_fleets[fleet.id] = fleet
	fleet_created.emit(fleet)
	return true

func delete_ship(ship: ShipData) -> bool:
	if not owns_ship(ship):
		return false
	_loaded_ships.erase(ship.id)
	ship.db = null
	ship.id = -1
	ship_deleted.emit(ship)
	return true

func delete_fleet(fleet: Fleet) -> bool:
	if not owns_fleet(fleet):
		return false
	_loaded_fleets.erase(fleet.id)
	fleet.db = null
	fleet.id = -1
	fleet_deleted.emit(fleet)
	return true
