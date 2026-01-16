class_name Fleet extends RefCounted

const DEFAULT_NAME := "Unnamed"
const CAPITAL_SHIP := 0

var name: String
var ships: Array[ShipDataID] = []

func _init(init_name := DEFAULT_NAME, init_num_ships := 10) -> void:
	name = init_name
	ships.resize(init_num_ships)

func is_unnamed() -> bool:
	return name == DEFAULT_NAME

func count_ships() -> int:
	return ships.size() - ships.count(null)

func has_slot(i: int) -> bool:
	return 0 <= i and i < ships.size()

func get_slot_name(i: int) -> String:
	return "CAPITAL" if i == 0 else ""
