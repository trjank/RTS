class_name ShipDataID extends RefCounted

signal ship_changed(new_ship_data: ShipData)
signal save_changed(is_saved: bool)

var id: int
var ship_data: ShipData:
	set = set_ship_data
var is_saved := false:
	set = save

func _init(init_ship_data: ShipData, init_id) -> void:
	id = init_id
	ship_data = init_ship_data

func set_ship_data(new_ship_data: ShipData) -> void:
	if new_ship_data == ship_data:
		return
	ship_data = new_ship_data
	ship_changed.emit(new_ship_data)

func save(save_status := true) -> void:
	is_saved = save_status
	save_changed.emit(save_status)

func _to_string() -> String:
	return ship_data.name + "#" + str(id)
