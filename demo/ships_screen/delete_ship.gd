extends TextureRect

signal delete_requested(ship: ShipData)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ShipButton

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.in_fleet:
		data.ship = null
	else:
		delete_requested.emit(data.ship)
