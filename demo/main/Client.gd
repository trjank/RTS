class_name Client2 extends RefCounted

signal fleet_changed(new_fleet: Fleet)

var rank: int
var name: String
var color: Color
var fleet: Fleet:
	set = set_fleet

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	fleet = new_fleet
	fleet_changed.emit(new_fleet)
