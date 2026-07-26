class_name Part extends Sprite3D

var data: PartData:
	set = set_data

var _ship: Ship

func _init() -> void:
	axis = Vector3.Axis.AXIS_Y
	pixel_size = Grid.METERS_PER_PX

func get_ship() -> Ship:
	return _ship

func get_size_2d() -> Vector2:
	return Grid.METERS_PER_TILE * data.get_size() if data != null else Vector2.ZERO

func get_size_3d() -> Vector3:
	var size_2d := get_size_2d()
	return Vector3(size_2d.x, 0.0, size_2d.y)

func get_up_direction() -> Vector3:
	return transform.basis.y

func get_forward_direction() -> Vector3:
	return -transform.basis.z

func get_global_up_direction() -> Vector3:
	return global_transform.basis.y

func get_global_forward_direction() -> Vector3:
	return -global_transform.basis.z

func set_data(new_data: PartData) -> void:
	if data != null:
		return push_error("Part.data is read only!")
	data = new_data
	texture = data.get_image().get_texture()

func _ship_init(ship_part: ShipDataPart, ship: Ship) -> void:
	_ship = ship
	var xy := Grid.METERS_PER_TILE * (ship_part.get_center() - Rect2(ship.data.get_ship_rect() ).get_center() )
	position.x = xy.x
	position.z = xy.y
	rotation = Grid.placement_to_rotation(ship_part.get_placement() )
	flip_h = Grid.is_placement_flipped(ship_part.get_placement() )

func _notification(what: int) -> void:
	if what != NOTIFICATION_PARENTED or _ship == null:
		return
	push_warning("(Part) Ship part reparented")
	_ship = null
