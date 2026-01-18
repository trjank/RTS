extends GridContainer

const MAX_NUM_SHIPS := 10
const SHIP_SLOT := preload("res://ships_screen/DraggableShip.tscn")

func _ready() -> void:
	return
	for ship in globals.ship_db.get_ships(MAX_NUM_SHIPS):
		var ship_slot := SHIP_SLOT.instantiate()
		ship_slot.ship_id = ship
		add_child(ship_slot)
