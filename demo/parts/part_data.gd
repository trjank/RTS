class_name PartData extends RefCounted

signal image_changed

const MIN_SIZE := 1
const MAX_SIZE := 16
const CODE_LENGTH := 4
const FALLBACK_CODE := "NULL"
const MAX_Z_INDEX := 100

static var subtypes: Dictionary[String, Callable] = {
	"": PartData.new,
	"weapon": WeaponData.new,
	"weapon_mount": WeaponMountData.new,
	"weapon_modifier": WeaponModifierData.new,
	"thruster": ThrusterData.new
}

static func create_subtype(part_subtype: String, part_code: String, part_image_path: String, part_width := MIN_SIZE, part_height := MIN_SIZE) -> PartData:
	return subtypes.get(part_subtype, PartData.new).call(part_code, part_image_path, part_width, part_height)

var atlas_id := -1
var z_index := 0:
	set = set_z_index
var name := ""
var tab := ""
var description := ""
var subtype := ""
var connected = true
var cost := 0
var warp := 0.0
var shield := 0.0
var energy := 0.0
var warp_per_sec := 0.0
var shield_per_sec := 0.0
var energy_per_sec := 0.0
var thrust := 0.0
var turn_impulse := 0.0
var hp := 0.0
var mass := 0.0
var image_path: String:
	set = set_image_path

var _code: String
var _size: Vector2i
var _image: PartImage

func _init(init_code: String, init_image_path: String, init_width := MIN_SIZE, init_height := MIN_SIZE) -> void:
	_code = init_code if init_code.length() == CODE_LENGTH else FALLBACK_CODE
	_size = Vector2i(init_width, init_height).clampi(MIN_SIZE, MAX_SIZE)
	image_path = init_image_path

func becomes_node_on_ship() -> bool:
	return false # <- MUST BE CONSTANT

func create_part() -> Part:
	var part := Part.new()
	part.data = self
	return part

func get_image() -> PartImage:
	return _image

func get_code() -> String:
	return _code

func get_width() -> int:
	return _size.x

func get_height() -> int:
	return _size.y

func get_size(placement := PartImage.Placement.ROT_0) -> Vector2i:
	return _size if placement % 2 == 0 else Vector2i(_size.y, _size.x)

func get_boundary(_placement := PartImage.Placement.ROT_0) -> int:
	return ShipData.BoundaryFlags.FULL

func set_z_index(new_z_index: int) -> void:
	z_index = mini(new_z_index, MAX_Z_INDEX)

func set_image_path(new_image_path: String) -> void:
	if image_path == new_image_path:
		return
	image_path = new_image_path
	_image = PartImage.new(new_image_path, _size.x, _size.y)
	image_changed.emit()
