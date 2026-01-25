class_name PartHitbox extends StaticBody2D

const OVERLAP_COLOR := Color.RED

@export var shape: CollisionShape2D

var placement: PartImage.Placement:
	get = get_placement,
	set = set_placement
var overlapping := false:
	set = set_overlapping
var data: PartData:
	set = set_data

var _part: Part

static func create() -> PartHitbox:
	return preload("res://design/part_hitbox.tscn").instantiate()

func get_size() -> Vector2:
	return Grid.TILE_SIZE * data.get_size()

func get_rect() -> Rect2:
	return _part.get_rect()

func get_global_rect() -> Rect2:
	return global_transform * _part.get_rect()

func remove_y_flip() -> void:
	if scale.y > 0:
		return
	scale = -scale
	rotation += PI

func get_top_left_corner() -> Vector2i:
	var rect := transform * get_rect()
	var corner := rect.position.snappedf(Grid.TILE_SIZE)
	# Return grid coordinates, not world coordinates
	return Vector2i(corner / Grid.TILE_SIZE)

func get_placement() -> PartImage.Placement:
	remove_y_flip()
	var flipped := scale.x < 0
	# Maps ≈0º -> 0, ≈90º -> 1, ≈180º -> 2, ≈270º -> 3
	var rot := int(round(rotation / (PI/2) ) ) & 3
	return (4 + rot if flipped else rot) as PartImage.Placement

func set_placement(new_placement: PartImage.Placement) -> void:
	rotation = (new_placement & 3) * (PI/2)
	scale.x = -1.0 if PartImage.Placement.FLIP_ROT_0 <= new_placement else 1.0 

func set_overlapping(is_overlapping: bool) -> void:
	z_index = (PartData.MAX_Z_INDEX + 1) if is_overlapping else data.z_index
	modulate = OVERLAP_COLOR if is_overlapping else Color.WHITE

func set_data(new_data: PartData) -> void:
	assert(new_data != null)
	# This just wraps an instance of the Part class
	if _part != null:
		_part.queue_free()
	data = new_data
	_part = new_data.create_part()
	z_index = data.z_index
	shape.shape.size = get_size()
	add_child(_part)
