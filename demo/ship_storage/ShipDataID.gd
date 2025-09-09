class_name ShipDataID extends RefCounted

var id := -1
var ship_data: ShipData = null

static func wrap_ship(init_ship_data: ShipData, init_id := -1)->ShipDataID:
	var ship_data_id := ShipDataID.new()
	ship_data_id.id = init_id
	ship_data_id.ship_data = init_ship_data
	return ship_data_id

func _to_string()->String:
	return ship_data.name + "#" + str(id)
