class_name Client extends RefCounted

signal fleet_changed(new_fleet: FleetID)

var rank: int
var name: String
var color: Color
var fleet: FleetID:
	set = set_fleet
var fleets: Dictionary[int, FleetID]

func set_fleet(new_fleet: FleetID) -> void:
	if fleet == new_fleet:
		return
	fleet = new_fleet
	fleet_changed.emit(new_fleet)
