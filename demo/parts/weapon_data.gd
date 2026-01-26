class_name WeaponData extends PartData

var projectile_code := "NULL"

func becomes_node_on_ship() -> bool:
	return true # <- MUST BE CONSTANT

func get_projectile() -> ProjectileData:
	return _manager.get_part_from_code(projectile_code) as ProjectileData

func get_boundary(_placement := PartImage.Placement.ROT_0) -> int:
	return ShipData.BoundaryFlags.NONE
