class_name Part extends ResizeableSprite2D

var data: PartData:
	set = set_data

func set_data(new_data: PartData) -> void:
	if data != null:
		return push_error("Part.data is read only!")
	data = new_data
	size = Grid.TILE_SIZE * data.get_size()
	texture = data.get_image().get_texture()

func ship_init(ship_part: ShipDataPart) -> void:
	position = ship_part.get_center()
	rotation = PartImage.placement_to_radians(ship_part.placement)
