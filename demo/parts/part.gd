@tool
class_name Part extends ResizeableSprite2D

var data: PartData:
	set = set_data

var _ship: Ship

func get_ship() -> Ship:
	return _ship

func _notification(what: int) -> void:
	if what != NOTIFICATION_PARENTED or _ship == null:
		return
	push_warning("Ship part reparented")
	_ship = null

func set_data(new_data: PartData) -> void:
	if data != null:
		return push_error("Part.data is read only!")
	data = new_data
	size = Grid.TILE_SIZE * data.get_size()
	texture = data.get_image().get_texture()

func _ship_init(ship_part: ShipDataPart, ship: Ship) -> void:
	_ship = ship
	position = Grid.TILE_SIZE * (ship_part.get_center() - Rect2(ship.data.get_ship_rect() ).get_center() )
	rotation = (ship_part.get_placement() & 3) * PI/2
	flip_h = PartImage.Placement.FLIP_ROT_0 <= ship_part.get_placement()
