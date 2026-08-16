class_name PartData extends RefCounted

signal image_changed()

const DEFAULT_SIZE := Vector2i.ONE
const MIN_SIZE := 1
const MAX_SIZE := 16
const CODE_LENGTH := 4
const FALLBACK_CODE := "NULL"
const MIN_Y := 0.0
const MAX_Y := 10.0 * Measurement.METERS_PER_TILE

static var subtypes: Dictionary[String, Callable] = {
	"": PartData.new,
	"weapon": WeaponData.new,
	"weapon_mount": WeaponMountData.new,
	"weapon_modifier": WeaponModifierData.new,
	"thruster": ThrusterData.new,
	"laser": LaserData.new,
	"bullet": BulletData.new,
	"death_ray": DeathRayData.new,
	"flamethrower": FlamethrowerData.new,
	"wing": WingData.new
}

var subtype := ""
var name := ""
var tab := ""
var description := ""
var image := ImageAsset.NOT_FOUND:
	set = set_image
var image_path: String:
	get = get_image_path,
	set = set_image_path
var cost := StrategicResources.new():
	set = set_cost
var cost_data: Dictionary:
	get = get_cost_data,
	set = set_cost_data
var y := 0.0:
	set = set_y
var hp := 0.0
var mass := 0.0
var warp := 0.0
var shield := 0.0
var energy := 0.0
var warp_per_sec := 0.0
var shield_per_sec := 0.0
var energy_per_sec := 0.0
var thrust := 0.0
var torque := 0.0

var _code: String
var _size: Vector2i
var _boundary := Boundary.FULL
var _manager: PartManager

static func create_subtype(const_subtype: String, const_code: String, const_size := DEFAULT_SIZE, const_boundary := Boundary.ALL_EDGES) -> PartData:
	return subtypes.get(const_subtype, PartData.new).call(const_code, const_size, const_boundary)

func _init(const_code: String, const_size := DEFAULT_SIZE, const_boundary := Boundary.ALL_EDGES) -> void:
	_code = const_code if const_code.length() == CODE_LENGTH else FALLBACK_CODE
	_size = const_size.clampi(MIN_SIZE, MAX_SIZE)
	_boundary = const_boundary

## This return value MUST be kept constant
func becomes_node_on_ship() -> bool:
	return false

func is_image_valid() -> bool:
	return image.get_size() == Measurement.PX_PER_TILE * _size

func get_manager() -> PartManager:
	return _manager

func get_code() -> String:
	return _code

func get_width() -> int:
	return _size.x

func get_height() -> int:
	return _size.y

func get_size() -> Vector2i:
	return _size

func get_boundary() -> int:
	return _boundary

func get_rotated_size(rotation: Rotation.Discrete) -> Vector2i:
	return _size if Rotation.is_even(rotation) else Vector2i(_size.y, _size.x)

func get_rotated_boundary(rotation: Rotation.Discrete) -> int:
	return Boundary.inverse_transform(_boundary, rotation)

func get_rotated_torque(_rotation: Rotation.Discrete) -> float:
	return torque

func get_rotated_thrust(_rotation: Rotation.Discrete) -> float:
	return thrust

func get_cost_data() -> Dictionary:
	return cost.to_dict()

func set_cost(new_cost: StrategicResources) -> void:
	cost = new_cost if new_cost != null else cost

func set_cost_data(new_cost_data: Dictionary) -> void:
	cost.load_dict(new_cost_data)

func set_y(new_y: float) -> void:
	y = clampf(new_y, MIN_Y, MAX_Y)

func get_image_path() -> String:
	return image.get_path()

func set_image_path(new_image_path: String) -> void:
	image = ImageAsset.use(new_image_path)

func set_image(new_image: ImageAsset) -> void:
	if new_image == null:
		new_image = ImageAsset.NOT_FOUND
	if new_image == image:
		return
	image = new_image
	image_changed.emit()

func create_ship_data_part(id := ShipData.NULL_ID, rect := Rect2i(), rotation := Rotation.Discrete.ROT_0, boundary := _boundary) -> ShipDataPart:
	return ShipDataPart.new(id, self, rect, rotation, boundary)

func create_part() -> Part:
	var part := Part.new()
	part.data = self
	return part
