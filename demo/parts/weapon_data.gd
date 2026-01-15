class_name WeaponData extends PartData

func get_boundary(_placement := PartImage.Placement.ROT_0) -> int:
	return ShipData.BoundaryFlags.NONE
