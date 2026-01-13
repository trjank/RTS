class_name Part extends ResizeableSprite2D

var data: PartData:
	set = set_data

func set_data(new_data: PartData) -> void:
	if data != null:
		return push_error("Part.data is read only!")
	data = new_data
	size = Grid.TILE_SIZE * data.get_size()
	texture = data.texture

func ship_init(ship_part: ShipDataPart) -> void:
	position = ship_part.get_center()
	rotation = ShipData.to_quadrant(ship_part.placement) * PI/2
