class_name PartData extends RefCounted

const MIN_WIDTH := 1
const MIN_HEIGHT := 1
const CODE_LENGTH := 4
const IMAGE_FOLDER := "res://part_images/"
const FALLBACK_TEXTURE := preload("res://icons/texture_not_found.png")
const DEFAULT_CODE := "NULL"

static var subtypes: Dictionary[String, Callable] = {
	"": PartData.new,
	"weapon": WeaponData.new,
	"weapon_mount": WeaponMountData.new,
	"weapon_modifier": WeaponModifierData.new,
	"thruster": ThrusterData.new
}

static func safe_texture(texture_2d: Texture2D) -> Texture2D:
	return FALLBACK_TEXTURE if texture_2d == null else texture_2d

static func create_subtype(part_subtype: String) -> PartData:
	return subtypes.get(part_subtype, PartData.new).call()

var atlas_id := -1
var z_index := 0
var name := ""
var tab := ""
var description := ""
var code := DEFAULT_CODE:
	set = set_code
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
var texture: Texture2D = FALLBACK_TEXTURE
var width := MIN_WIDTH:
	set = set_width
var height := MIN_HEIGHT:
	set = set_height
var image_path: String:
	set = set_image_path

var image: Image

var atlas_rect: Rect2

func becomes_node_on_ship() -> bool:
	return false

func create_part() -> Part:
	var part := Part.new()
	part.data = self
	return part

func set_width(new_width: int) -> void:
	width = maxi(new_width, MIN_WIDTH)

func set_height(new_height: int) -> void:
	height = maxi(new_height, MIN_HEIGHT)

func get_size(placement := ShipData.Placement.ROT_0_DEG) -> Vector2i:
	return Vector2i(width, height) if placement % 2 == 0 else Vector2i(height, width)

func get_boundary(_placement := ShipData.Placement.ROT_0_DEG) -> int:
	return ShipData.BoundaryFlags.FULL

func set_code(new_code: String) -> void:
	if code == DEFAULT_CODE and new_code.length() == CODE_LENGTH:
		code = new_code
	else:
		push_error("Unable to set PartData code '%s' to '%s'" % [code, new_code] )

func set_image_path(new_image_path: String) -> void:
	new_image_path = IMAGE_FOLDER + new_image_path
	# NOTE: '..' could expose the user's personal files, so it is not allowed
	if new_image_path.contains(".."):
		return push_error("Image path '%s' contains '..'" % new_image_path)
	var new_texture := ResourceLoader.load(new_image_path) as Texture2D
	texture = safe_texture(new_texture)
	image_path = new_image_path
	image = texture.get_image()
