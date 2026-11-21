class_name ShipDataWeapon extends ShipDataPart

const MOUNT_TOLERANCE := 0.5

var _mount: ShipDataWeaponMount

func _init(init_id: int, init_data: WeaponData, init_rect: Rect2i, init_rotation: Rotation.Discrete, init_boundary: int) -> void:
	super(init_id, init_data, init_rect, init_rotation, init_boundary)

func has_mount() -> bool:
	return _mount != null

func get_mount() -> ShipDataWeaponMount:
	return _mount

func get_data() -> WeaponData:
	return _data

func is_mount_compatible() -> bool:
	return _mount != null and (get_center() - _mount.get_center() ).abs() < MOUNT_TOLERANCE * Vector2.ONE

func on_ship_data_pre_finalize(ship_data: ShipData) -> ShipData.PlacementError:
	_mount = ship_data.part_atv(get_center() ) as ShipDataWeaponMount
	return ShipData.PlacementError.OK if is_mount_compatible() else ShipData.PlacementError.WEAPON_HAS_NO_MOUNT
