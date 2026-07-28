class_name ShipDataPart extends RefCounted

var _id: int
var _data: PartData
var _rect: Rect2i
var _rotation: Rotation.Discrete
var _boundary: int
var _calculations := {}

func _init(init_id: int, init_data: PartData, init_rect: Rect2i, init_rotation: Rotation.Discrete, init_boundary: int) -> void:
	_id = init_id
	_data = init_data
	_rect = init_rect
	_rotation = init_rotation
	_boundary = init_boundary

func get_id() -> int:
	return _id

func get_data() -> PartData:
	return _data

func get_center() -> Vector2:
	return Rect2(_rect).get_center()

func get_rect() -> Rect2i:
	return _rect

func get_rotation() -> Rotation.Discrete:
	return _rotation

func get_image() -> Image:
	return _data.image.get_image(_rotation)

func get_boundary() -> int:
	return _boundary

func get_calculations() -> Dictionary:
	return _calculations
