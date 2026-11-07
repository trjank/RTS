class_name Fleet extends RefCounted

signal resized(new_size: int)
signal renamed(new_name: String)
signal priority_changed
signal ship_changed(new_ship: ShipData, slot: int)
signal save_changed(is_saved: bool)

const MIN_SIZE := 1
const MAX_SIZE := 20
const MAX_NAME_LENGTH := 50
const CAPITAL_SHIP_SLOT := 0

static var PROPERTIES: Dictionary[String, Variant.Type] = {
	"size": TYPE_INT,
	"priority": TYPE_INT,
	"name": TYPE_STRING
}
static var DB_PROPERTIES: Dictionary[String, Variant.Type] = {
	"id": TYPE_INT
}

var size: int:
	get = get_size, set = set_size
var name := "":
	set = set_name
var db: ShipManager:
	get = get_db, set = set_db
var id := -1
var priority := 0:
	set = set_priority
var saved := true:
	set = set_saved

var _ships: Array[ShipData] = [null]
var _db: WeakRef = weakref(null)

static func _static_init() -> void:
	DB_PROPERTIES.merge(PROPERTIES)

static func from_uid(uid: int) -> Fleet:
	var static_db := ShipManager.from_id(uid & ShipManager.MAX_ID)
	return static_db.get_fleet(uid >> ShipManager.ID_BITS) if static_db != null else null

static func from_dict(dict: Dictionary, use_id := false, default: Fleet = null) -> Fleet:
	var fleet := Fleet.new()
	return fleet if fleet.load_dict(dict, use_id) else default

func get_uid() -> int:
	return (db.get_id() if db != null else 0) | (id << ShipManager.ID_BITS)

func to_dict(use_id := false) -> Dictionary:
	return TypeChecker.to_dict(self, DB_PROPERTIES if use_id else PROPERTIES)

func load_dict(dict: Dictionary, use_id := false) -> bool:
	return TypeChecker.load_dict(self, dict, DB_PROPERTIES if use_id else PROPERTIES, TypeChecker.CAST_NUMBERS)

func get_size() -> int:
	return _ships.size()

func get_db() -> ShipManager:
	return _db.get_ref()

func set_priority(new_priority: int) -> void:
	if priority == new_priority:
		return
	priority = new_priority
	priority_changed.emit()

func set_saved(new_saved: bool) -> void:
	if new_saved == saved:
		return
	saved = new_saved
	save_changed.emit(saved)

func sync_metadata() -> bool:
	return _db != null and _db.sync_fleet_metadata(self)

func sync_ships() -> bool:
	return _db != null and _db.sync_fleet_ships(self)

func sync() -> bool:
	return _db != null and _db.sync_fleet(self)

func save_metadata() -> bool:
	return _db != null and _db.save_fleet_metadata(self)

func save_ships() -> bool:
	return _db != null and db.save_fleet_ships(self)

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

func set_db(new_db: ShipManager) -> void:
	_db = weakref(new_db)

## For one-line set and save do: var success := set_ship(..) and save_ships()
func set_ship(slot: int, ship: ShipData) -> bool:
	if not has_slot(slot) or ship == _ships[slot]:
		return false
	_ships[slot] = ship
	ship_changed.emit(ship, slot)
	return true

## For one-line set and save do: var success := set_name(..) and save_metadata()
func set_name(new_name: String) -> bool:
	new_name = new_name.substr(0, MAX_NAME_LENGTH)
	if name == new_name:
		return false
	name = new_name
	renamed.emit(name)
	return true

## For one-line set and save do: var success := set_size(..) and save_metadata()
func set_size(new_size: int) -> bool:
	new_size = clampi(new_size, MIN_SIZE, MAX_SIZE)
	if size == new_size:
		return false
	_ships.resize(new_size)
	resized.emit(new_size)
	return true
