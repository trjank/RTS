class_name CPUImageBuilder extends RefCounted

static func rotate_image(image: Image, rotation: PartData.Rotation, flipped: bool)->Image:
	if rotation == PartData.ROT_0_DEG: return image
	image = image.duplicate()
	if flipped: image.flip_x()
	match rotation:
		PartData.ROT_0_DEG:
			pass
		PartData.ROT_90_DEG:
			image.rotate_90(CLOCKWISE)
		PartData.ROT_180_DEG:
			image.rotate_180()
		PartData.ROT_270_DEG:
			image.rotate_90(COUNTERCLOCKWISE)
	return image
	

static func build_image(ship: ShipData)->void:
	var size  := ship.get_grid_region().size
	var image := Image.create(size.x, size.y, true, Image.FORMAT_RGBA8)
	for n in range(ship.count_parts()):
		var id := 1 + n
		var part := ship.get_part_data(id)
		var rect := ship.get_part_region(id)
		var pimage := rotate_image(part.get_image(), ship.get_part_rotation(id), ship.is_part_flipped(id))
		image.blit_rect(pimage, Rect2i(0, 0, rect.size.x, rect.size.y), rect.position)
	ship.set_image(image)
	image.save_png("res://TEST_IMAGE.png")
