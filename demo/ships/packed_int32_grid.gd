class_name PackedInt32Grid extends RefCounted

const MIN_SIZE := Vector2i.ONE

var size: Vector2i:
	set = set_size

var _buffer: PackedInt32Array

func _init(init_size := MIN_SIZE, init_buffer := PackedInt32Array() ) -> void:
	_buffer = init_buffer
	size = init_size

func set_size(new_size: Vector2i) -> void:
	size = new_size.max(MIN_SIZE)
	_buffer.resize(size.x * size.y)

func fill(value: int) -> void:
	_buffer.fill(value)

func get_int(x: int, y: int) -> int:
	return _buffer[calculate_index(x, y) ]

func get_intv(point: Vector2i) -> int:
	return get_int(point.x, point.y)

func set_int(x: int, y: int, value: int) -> void:
	_buffer[calculate_index(x, y) ] = value

func set_intv(point: Vector2i, value: int) -> void:
	_buffer[calculate_index(point.x, point.y) ] = value
 
func calculate_index(x: int, y: int) -> int:
	return x + size.x * y

func copy() -> PackedInt32Grid:
	return PackedInt32Grid.new(size, _buffer)

func fill_rect(rect: Rect2i, value: int) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			set_int(x, y, value)

func compare_rect(rect: Rect2i, value: int) -> bool:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if get_int(x, y) != value:
				return false
	return true
