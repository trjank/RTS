class_name PartHitbox extends StaticBody3D

const COLORED_OVERLAY := preload("res://effects/colored_overlay.tres")

@export var collision_shape: CollisionShape3D

var placement: Grid.PartPlacement:
	get = get_placement,
	set = set_placement
var overlapping := false:
	set = set_overlapping
var data: PartData:
	set = set_data

var _part: Part

static func create() -> PartHitbox:
	return preload("res://design/part_hitbox.tscn").instantiate()

func _ready() -> void:
	collision_layer = globals.Layer.PARTS

func get_size_2d() -> Vector2:
	return Grid.METERS_PER_TILE * data.get_size() if data != null else Vector2.ZERO

func get_size_3d() -> Vector3:
	var size_2d := get_size_2d()
	return Vector3(size_2d.x, 0.0, size_2d.y)

## NOTE: This returns position in grid tiles, NOT meters or pixels
func get_top_left_corner() -> Vector2i:
	var corner := position - 0.5 * (transform.basis * get_size_3d() ).abs()
	var corner_2d := Grid.TILES_PER_METER * Vector2(corner.x, corner.z)
	return Vector2i(corner_2d.round() )

func get_placement() -> Grid.PartPlacement:
	var h_flip := scale.x < 0
	var v_flip := scale.z < 0
	var h_rotation := rotation.y + PI if v_flip else rotation.y
	# NOTE: Godot's transform implementation often flips negative signs
	return Grid.to_placement(h_flip and v_flip, Vector3(0.0, h_rotation, 0.0) )

func set_placement(new_placement: Grid.PartPlacement) -> void:
	rotation = Grid.placement_to_rotation(new_placement)
	scale.x = -1.0 if Grid.is_placement_flipped(new_placement) else 1.0 

func set_overlapping(is_overlapping: bool) -> void:
	assert(_part != null, "(PartHitbox) PartData is required to test overlap")
	#
	overlapping = is_overlapping
	_part.material_overlay = COLORED_OVERLAY if overlapping else null

func set_data(new_data: PartData) -> void:
	if new_data == null:
		return push_error("(PartHitbox) PartData cannot be null")
	if _part != null:
		_part.queue_free()
	data = new_data
	_part = new_data.create_part()
	position.y = data.y_level
	collision_shape.shape.size = get_size_3d()
	add_child(_part)
