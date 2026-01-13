class_name FleetID extends RefCounted

var id := -1
var fleet: Fleet

func _init(init_fleet: Fleet, init_id := -1) -> void:
	id = init_id
	fleet = init_fleet

func _to_string() -> String:
	return fleet.name + "#" + str(id)
