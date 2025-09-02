class_name ShipDataID extends RefCounted

var id: int = -1
var ship_data: ShipData = null

static func wrap_ship(init_ship_data: ShipData, init_id: int)->ShipDataID:
	var ship_data_id := ShipDataID.new()
	ship_data_id.id = init_id
	ship_data_id.ship_data = init_ship_data
	return ship_data_id
