class_name WeaponMountData extends PartData

var modifiers := WeaponModifiers.new():
	set = set_modifiers
var arc_degrees := 90.0
var modifier_boundary := Boundary.FULL
var modifier_efficiency := 1.0
 
func set_modifiers(new_modifiers: WeaponModifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else modifiers

func create_ship_data_part(id := ShipData.NULL_ID, rect := Rect2i(), rotation := Rotation.Discrete.ROT_0, boundary := _boundary) -> ShipDataPart:
	return ShipDataWeaponMount.new(id, self, rect, rotation, boundary)
