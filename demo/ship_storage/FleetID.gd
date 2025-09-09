class_name FleetID extends RefCounted

var id := -1
var fleet: Fleet = null

static func wrap_fleet(init_fleet: Fleet, init_id := -1)->FleetID:
	var fleet_id := FleetID.new()
	fleet_id.id = init_id
	fleet_id.fleet = init_fleet
	return fleet_id

func _to_string()->String:
	return fleet.name + "#" + str(id)
