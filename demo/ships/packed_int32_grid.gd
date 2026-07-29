class_name PackedInt32Grid extends RefCounted

const MIN_SIZE := Vector2i.ONE

var size: Vector2i:
	set = set_size
var _grid := PackedInt32Array()

func _init(init_size := MIN_SIZE) -> void:
	size = init_size

func set_size(new_size: Vector2i) -> void:
	size = new_size.max(MIN_SIZE)
	_grid.resize(size.x * size.y)

func fill(value: int) -> void:
	_grid.fill(value)

func get_int(x: int, y: int) -> int:
	return _grid[_index_of(x, y) ]

func get_intv(point: Vector2i) -> int:
	return get_int(point.x, point.y)

func set_int(x: int, y: int, value: int) -> void:
	_grid[_index_of(x, y) ] = value

func _index_of(x: int, y: int) -> int:
	return x + size.x * y

# TODO: If this becomes a bottleneck, write this in c++
func fill_rect(rect: Rect2i, value: int) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			set_int(x, y, value)

# TODO: If this becomes a bottleneck, write this in c++
func is_rect_empty(rect: Rect2i, default_value := 0) -> bool:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if get_int(x, y) != default_value:
				return false
	return true
