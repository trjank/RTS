class_name Account extends RefCounted

signal fleet_changed(new_fleet: Fleet)

static var me := Account.new():
	set(__): push_error("(Account) Account.me is immutable!")

var name := ""
var icon := Player.Icon.NONE
var fleet: Fleet:
	set = set_fleet
var color := Color.WHITE

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	fleet = new_fleet
	fleet_changed.emit(new_fleet)
