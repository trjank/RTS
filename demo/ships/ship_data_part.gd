class_name ShipDataPart extends RefCounted

var _id: int
var _data: PartData
var _rect: Rect2i
var _placement: Grid.PartPlacement
var _boundary: int

func _init(init_id: int, init_data: PartData, init_rect: Rect2i, init_placement: Grid.PartPlacement, init_boundary: int) -> void:
	_id = init_id
	_data = init_data
	_rect = init_rect
	_placement = init_placement
	_boundary = init_boundary

func get_center() -> Vector2:
	return Rect2(_rect).get_center()

func get_id() -> int:
	return _id

func get_data() -> PartData:
	return _data

func get_rect() -> Rect2i:
	return _rect

func get_placement() -> Grid.PartPlacement:
	return _placement

func get_image() -> Image:
	return _data.get_image().get_image(_placement)

func get_boundary() -> int:
	return _boundary
