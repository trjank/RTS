class_name WeaponData extends PartData

var projectile_code := "NULL"

func _init(const_code: String, const_size := DEFAULT_SIZE, _const_boundary := Boundary.ALL_EDGES) -> void:
	super(const_code, const_size, Boundary.NONE)

func becomes_node_on_ship() -> bool:
	return true

func get_projectile() -> ProjectileData:
	return _manager.get_part(projectile_code) as ProjectileData

func create_ship_data_part(id := ShipData.NULL_ID, rect := Rect2i(), rotation := Rotation.Discrete.ROT_0, boundary := _boundary) -> ShipDataPart:
	return ShipDataWeapon.new(id, self, rect, rotation, boundary)

func create_part() -> Part:
	var weapon := Weapon.new()
	weapon.data = self
	return weapon
