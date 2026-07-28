class_name WeaponMountData extends PartData

var modifiers := WeaponModifiers.new()
var angle_degrees := 0.0
var arc_degrees := 0.0
var modifier_boundary_flags: int = Boundary.FULL

func on_ship_data_finalize(ship_data: ShipData) -> void:
	var final_modifiers := WeaponModifiers.new()
	final_modifiers.add(modifiers)
	ship_data.for_each_neighbor(1, modifier_boundary_flags, final_modifiers.add)
