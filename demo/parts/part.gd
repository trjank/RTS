class_name Part extends Sprite3D

var data: PartData:
	set = set_data

var _ship: Ship

func _init() -> void:
	axis = Vector3.Axis.AXIS_Y
	pixel_size = Measurement.METERS_PER_PX
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

func get_ship() -> Ship:
	return _ship

func get_player_owner() -> Player:
	return _ship.player_owner if _ship != null else null

func get_size_2d() -> Vector2:
	return Measurement.METERS_PER_TILE * data.get_size() if data != null else Vector2.ZERO

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
	texture = data.image.get_texture()

func on_ship_ready(ship_part: ShipDataPart, ship: Ship) -> void:
	_ship = ship
	var xy := Measurement.METERS_PER_TILE * (ship_part.get_center() - Rect2(ship.data.get_ship_rect() ).get_center() )
	position = Vector3(xy.x, data.y, xy.y)
	rotation.y = Rotation.to_radians(ship_part.get_rotation() )
	scale.x = -1.0 if Rotation.is_flip_h(ship_part.get_rotation() ) else 1.0

func _notification(what: int) -> void:
	if what != NOTIFICATION_PARENTED or _ship == null:
		return
	push_warning("(Part) Ship part reparented")
	_ship = null
