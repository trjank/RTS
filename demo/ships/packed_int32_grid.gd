class_name PackedInt32Grid extends RefCounted

var size := Vector2i.ZERO: set = resize
var _grid := PackedInt32Array()

func resize(new_size: Vector2i) -> void:
	_grid.resize(new_size.x * new_size.y)

func fill(value: int) -> void:
	_grid.fill(value)

func get_cell(x: int, y: int) -> int:
	return _grid[_index_of(x, y) ]

func set_cell(x: int, y: int, value: int) -> void:
	_grid[_index_of(x, y) ] = value

func _index_of(x: int, y: int) -> int:
	return x + size.x * y
