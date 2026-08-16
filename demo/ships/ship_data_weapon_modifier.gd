class_name ShipDataWeaponModifier extends ShipDataPart

var _modifiers := WeaponModifiers.new()
var _modshare_efficiency := 1.0
var _useless := true

func _init(init_id: int, init_data: WeaponModifierData, init_rect: Rect2i, init_rotation: Rotation.Discrete, init_boundary: int) -> void:
	super(init_id, init_data, init_rect, init_rotation, init_boundary)

func is_useless() -> bool:
	return _useless

func get_data() -> WeaponModifierData:
	return _data

func get_modifiers() -> WeaponModifiers:
	return _modifiers

func get_modshare_efficiency() -> float:
	return _modshare_efficiency

func _update_modshare_efficiency(part_data: PartData) -> void:
	if not part_data is WeaponMountData:
		return
	_useless = false
	_modshare_efficiency *= _data.modshare_efficiency

func on_ship_data_pre_finalize(ship_data: ShipData) -> ShipData.PlacementError:
	_useless = true
	_modifiers.reset()
	_modifiers.add(_data.modifiers)
	_modshare_efficiency = 1.0
	#
	for part_id in ship_data.get_neighbors(_id, _data.modifier_boundary):
		_update_modshare_efficiency(ship_data.get_part_data(part_id) )
	_modifiers.apply_efficiency(_modshare_efficiency)
	return ShipData.PlacementError.USELESS_MODIFIER if _useless else ShipData.PlacementError.OK
