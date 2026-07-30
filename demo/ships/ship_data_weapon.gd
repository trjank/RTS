class_name ShipDataWeapon extends ShipDataPart

var _mount: ShipDataWeaponMount

func get_mount() -> ShipDataWeaponMount:
	return _mount

func is_mount_compatible() -> bool:
	return _mount != null and get_center() == _mount.get_center()

func on_ship_data_pre_finalize(ship_data: ShipData) -> ShipData.PlacementError:
	_mount = ship_data.part_atv(get_center() ) as ShipDataWeaponMount
	return ShipData.PlacementError.OK if is_mount_compatible() else ShipData.PlacementError.WEAPON_HAS_NO_MOUNT
