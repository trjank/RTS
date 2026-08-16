class_name PartHitbox extends StaticBody3D

const COLORED_OVERLAY := preload("res://effects/colored_overlay.tres")

@export var collision_shape: CollisionShape3D

var discrete_rotation: Rotation.Discrete:
	get = get_discrete_rotation,
	set = set_discrete_rotation
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
	return Measurement.METERS_PER_TILE * data.get_size() if data != null else Vector2.ZERO

func get_size_3d() -> Vector3:
	var size_2d := get_size_2d()
	return Vector3(size_2d.x, 0.0, size_2d.y)

## NOTE: This returns position in grid tiles, NOT meters or pixels
func get_top_left_corner() -> Vector2i:
	var corner := position - 0.5 * (transform.basis * get_size_3d() ).abs()
	var corner_2d := Measurement.TILES_PER_METER * Vector2(corner.x, corner.z)
	return Vector2i(corner_2d.round() )

func get_discrete_rotation() -> Rotation.Discrete:
	# NOTE: Do NOT use scale.x and rotation.y (there are multiple equivalent transforms)
	var h_flip := basis.x.cross(basis.z).y > 0.0
	var xz_rotation := atan2(-basis.x.z, basis.x.x)
	return Rotation.from_radians(xz_rotation + PI if h_flip else xz_rotation, h_flip)

func set_discrete_rotation(new_rotation: Rotation.Discrete) -> void:
	rotation.y = Rotation.to_radians(new_rotation)
	scale.x = -1.0 if Rotation.is_flip_h(new_rotation) else 1.0 

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
	collision_shape.shape.size = get_size_3d()
	add_child(_part)
	position.y = data.y
	_part.position.y = 0.0
