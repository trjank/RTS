class_name ShipDataWeaponMount extends ShipDataPart

var _modifiers := WeaponModifiers.new()

func get_modifiers() -> WeaponModifiers:
	return _modifiers

func _add_modifier(part_data: ShipDataPart) -> void:
	if part_data is ShipDataWeaponModifier:
		_modifiers.add(part_data.get_modifiers() )
	# TODO: Other parts may have special effects?

func on_ship_data_post_finalize(ship_data: ShipData) -> ShipData.PlacementError:
	_modifiers.reset()
	_modifiers.add(_data.modifiers)
	#
	for part_id in ship_data.get_neighbors(_id, _boundary):
		_add_modifier(ship_data.get_part(part_id) )
	_modifiers.apply_efficiency(_data.modifier_efficiency)
	return ShipData.PlacementError.OK
