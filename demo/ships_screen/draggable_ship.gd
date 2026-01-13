extends PanelContainer

var ship_id: ShipDataID: set = set_ship

@onready var image := $TextureRect

func set_ship(new_ship_id: ShipDataID)->void:
	ship_id       = new_ship_id
	image.texture = new_ship_id.ship_data.get_image()

func _can_drop_data(_at_position: Vector2, _data: Variant)->bool:
	return true

func _get_drag_data(_at_position: Vector2)->Variant:
	if ship_id == null: return null
	# We need an extra control to center the image
	var center  := Control.new()
	var preview := duplicate()
	center.add_child(preview)
	preview.position -= 0.5 * size
	set_drag_preview(center)
	return self

func _drop_data(_at_position: Vector2, data: Variant)->void:
	var old_ship_id := ship_id
	# Swap the ships of the two slots
	ship_id      = data.ship_id
	data.ship_id = old_ship_id
