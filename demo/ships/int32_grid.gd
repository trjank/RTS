class_name Int32Grid extends RefCounted

var _image: Image

# This is VERY cursed, but it makes debugging easier

func _init(width: int, height: int) -> void:
	_image = Image.create_empty(width, height, false, Image.FORMAT_RF)

func debug_export_as_png(save_path: String) -> Error:
	return _image.save_png(save_path)

func resize(width: int, height: int) -> void:
	_image.resize(width, height, Image.INTERPOLATE_NEAREST)

func encode_int(value: int) -> Color:
	return Color(float(value), 0, 0, 1)

func decode_int(color: Color) -> int:
	return int(color.r)

func get_int(x: int, y: int) -> int:
	return decode_int(_image.get_pixel(x, y) )

func get_intv(point: Vector2i) -> int:
	return get_int(point.x, point.y)

func set_int(x: int, y: int, value: int) -> void:
	_image.set_pixel(x, y, encode_int(value) )

func fill(value: int) -> void:
	_image.fill(encode_int(value))

func fill_rect(rect: Rect2i, value: int) -> void:
	_image.fill_rect(rect, encode_int(value) )

func rect_equals(rect: Rect2i, value: int) -> bool:
	var color := encode_int(value)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if _image.get_pixel(x, y) != color:
				return false
	return true
