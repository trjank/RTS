class_name WeaponData extends PartData

func get_boundary(_placement := ShipData.Placement.ROT_0_DEG) -> int:
	return ShipData.BoundaryFlags.NONE
