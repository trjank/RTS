class_name PartHitbox extends StaticBody2D

@export var shape: CollisionShape2D

var data: PartData:
	set = set_data

var _part: Part

static func create() -> PartHitbox:
	return preload("res://design/part_hitbox.tscn").instantiate() as PartHitbox

func is_flipped() -> bool:
	return (scale.x < 0) != (scale.y < 0)

func get_size() -> Vector2:
	return Grid.TILE_SIZE * data.get_size()

func get_rect() -> Rect2:
	return _part.get_rect()

func get_global_rect() -> Rect2:
	return global_transform * _part.get_rect()

func get_top_left_corner() -> Vector2i:
	return Vector2i((transform * get_rect()).position / Grid.TILE_SIZE)

func get_placement() -> PartImage.Placement:
	return PartImage.to_placement(rotation, is_flipped() )

func set_data(new_data: PartData) -> void:
	assert(new_data != null)
	if _part != null:
		_part.queue_free()
	data = new_data
	_part = new_data.create_part()
	z_index = data.z_index
	shape.shape.size = get_size()
	add_child(_part)
