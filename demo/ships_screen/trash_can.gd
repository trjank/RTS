extends TextureRect

func delete_ship(ship_button: ShipButton) -> void:
	if ship_button.in_fleet:
		ship_button.ship = null
	else:
		ship_button.delete()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ShipButton or data is FleetContainer

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is FleetContainer:
		data.delete_fleet()
	elif data is ShipButton:
		data.delete_ship()
