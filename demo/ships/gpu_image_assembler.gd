class_name GPUImageAssembler extends SubViewport

@export var ship: Node2D

func assemble(ship_data: ShipData) -> Image:
	size = 32 * ship_data.get_ship_rect().size
	ship.data = ship_data
	ship.queue_redraw()
	await RenderingServer.frame_post_draw
	return get_texture().get_image()

func assemble_naive(ship_data: ShipData) -> Image:
	var xy0 := ship_data.get_ship_rect().position
	var dim := 32 * ship_data.get_ship_rect().size
	var image := Image.create_empty(dim.x, dim.y, false, Image.FORMAT_RGBA8)
	ship_data.for_each_part(func (part: ShipDataPart) -> void:
		var rect := Rect2i(Vector2i.ZERO, 32 * part.rect.size)
		#image.rotate_90(CLOCKWISE)
		image.blit_rect(part.data.image, rect, 32 * (part.rect.position - xy0))
	)
	return image
