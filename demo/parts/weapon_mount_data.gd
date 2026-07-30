class_name WeaponMountData extends PartData

var modifiers := WeaponModifiers.new()
var angle_degrees := 0.0
var arc_degrees := 0.0
var modifier_boundary := Boundary.FULL
var modifier_efficiency := 1.0

func create_ship_data_part(id := ShipData.NULL_ID, rect := Rect2i(), rotation := Rotation.Discrete.ROT_0, boundary := _boundary) -> ShipDataPart:
	return ShipDataWeaponMount.new(id, self, rect, rotation, boundary)
