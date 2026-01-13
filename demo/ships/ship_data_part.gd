class_name ShipDataPart extends RefCounted

var id := ShipData.NULL_PART_ID:
	set = set_id
var data: PartData:
	set = set_data
var rect: Rect2i:
	set = set_rect
var placement := ShipData.Placement.INVALID:
	set = set_placement

func _init(init_id: int, init_data: PartData, init_rect: Rect2i, init_placement: ShipData.Placement) -> void:
	id = init_id
	data = init_data
	rect = init_rect
	placement = init_placement

func get_center() -> Vector2:
	return Rect2(rect).get_center()

func set_id(new_id: int) -> void:
	assert(id == ShipData.NULL_PART_ID)
	id = new_id

func set_data(new_data: PartData) -> void:
	assert(data == null)
	data = new_data

func set_rect(new_rect: Rect2i) -> void:
	assert(rect.size == Vector2i.ZERO)
	rect = new_rect

func set_placement(new_placement: ShipData.Placement) -> void:
	assert(ShipData.is_valid(new_placement) )
	placement = new_placement
