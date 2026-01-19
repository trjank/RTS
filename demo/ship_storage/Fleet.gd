class_name Fleet extends RefCounted

signal renamed(new_name: String)
signal ship_changed(slot: int, new_ship: ShipDataID)

const MAX_NAME_LENGTH := 30
const DEFAULT_NAME := "Unnamed"
const DEFAULT_SIZE := 10
const CAPITAL_SHIP_SLOT := 0

var name: String:
	set = set_name

var _ships: Array[ShipDataID] = []

func _init(init_name := DEFAULT_NAME, init_num_ships := DEFAULT_SIZE) -> void:
	name = init_name
	_ships.resize(init_num_ships)

func is_unnamed() -> bool:
	return name == DEFAULT_NAME

func size() -> int:
	return _ships.size()

func has_slot(slot: int) -> bool:
	return 0 <= slot and slot < _ships.size()

func has_ship_in_slot(slot: int) -> bool:
	var ship := _ships[slot]
	return ship != null and ship.ship_data != null and not ship.ship_data.is_empty()

func get_ship(slot: int) -> ShipDataID:
	return _ships[slot] if has_slot(slot) else null

func set_name(new_name: String) -> void:
	name = new_name.substr(0, MAX_NAME_LENGTH)
	renamed.emit(name)

func set_ship(slot: int, ship: ShipDataID) -> bool:
	if not has_slot(slot):
		return false
	_ships[slot] = ship
	ship_changed.emit(slot, ship)
	return true

func for_each_ship(f: Callable) -> void:
	for slot in _ships.size():
		f.call(_ships[slot], slot)
