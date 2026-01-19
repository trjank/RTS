extends TextureRect

signal delete_requested(ship: ShipDataID)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ShipButton and not data.in_fleet

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	delete_requested.emit(data.ship)
