class_name DraggableShipButton extends ShipButton

static func create() -> DraggableShipButton:
	return preload("res://ships_screen/draggable_ship_button.tscn").instantiate() as DraggableShipButton

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _get_drag_data(_at_position: Vector2) -> Variant:
	var center := Control.new()
	var preview := duplicate()
	center.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(center)
	return self

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var old_ship := ship
	ship = data.ship
	data.ship = old_ship
