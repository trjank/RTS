class_name Fleet extends RefCounted

var name := "Unnamed"
var slots: Dictionary[String, Array] = {}

func create_slot(slot_name: String, num_ships: int)->bool:
	if slots.has(slot_name) or num_ships <= 0: return false
	# Store id wrappers to allow saving and loading
	var ships: Array[ShipDataID] = []
	ships.resize(num_ships)
	return slots.set(slot_name, ships)

func set_ship(slot_name: String, slot_num: int, ship: ShipDataID)->bool:
	var ships := slots[slot_name]
	if ships == null or slot_num < 0 or ships.size() <= slot_num: return false
	ships[slot_num] = ship
	return true
