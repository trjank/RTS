class_name DraggableShip extends PanelContainer

var ship_id: ShipDataID: set = set_ship
var ship_image: TextureRect

func set_ship(new_ship_id: ShipDataID) -> void:
	ship_id = new_ship_id
	ship_image.texture = preload("res://icons/icon.svg")

func _ready() -> void:
	ship_image = TextureRect.new()
	add_child(ship_image)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _get_drag_data(_at_position: Vector2) -> Variant:
	if ship_id == null: return null
	# Create a copy of this for the mouse
	var preview := duplicate()
	set_drag_preview(preview)
	return self

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var old_ship_id := ship_id
	# Swap the ships of the two slots
	ship_id = data.ship_id
	data.ship_id = old_ship_id
