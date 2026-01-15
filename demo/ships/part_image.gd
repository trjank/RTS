class_name PartImage extends RefCounted

# DO NOT CHANGE THIS ORDER!
enum Placement {
	ROT_0,
	ROT_90,
	ROT_180,
	ROT_270,
	FLIP_ROT_0,
	FLIP_ROT_90,
	FLIP_ROT_180,
	FLIP_ROT_270,
	NUM_PLACEMENTS
}

const ROTATION_INCREMENT := deg_to_rad(90.)
const TILE_SIZE := 32
const FORMAT := Image.FORMAT_RGBA8
const FOLDER_PATH := "res://part_images/"
const DEFAULT_TEXTURE: Texture2D = preload("res://icons/texture_not_found.png")

var _texture: Texture2D
var _cached_images: Array[Image] = []

static func is_placement_valid(placement: Placement) -> bool:
	return 0 <= placement and placement < Placement.NUM_PLACEMENTS

static func is_placement_flipped(placement: Placement) -> bool:
	return placement > Placement.ROT_270

static func placement_to_radians(placement: Placement) -> float:
	return (placement % 4) * ROTATION_INCREMENT

static func to_placement(radians: float, flipped := false) -> Placement:
	var quadrant := int(round(fposmod(radians, TAU) / ROTATION_INCREMENT) ) % 4
	return ( (quadrant + 4) if flipped else quadrant) as Placement

func _init(path: String, tiles_wide := 1, tiles_tall := 1) -> void:
	if path.contains("..") or not path.begins_with(FOLDER_PATH):
		push_error("PartImage path '%s' is invalid" % path)
	else:
		_texture = load(path) as Texture2D
	if _texture == null:
		_texture = DEFAULT_TEXTURE
	var image := _texture.get_image()
	image.convert(FORMAT)
	image.resize(TILE_SIZE * tiles_wide, TILE_SIZE * tiles_tall)
	_cached_images.resize(Placement.NUM_PLACEMENTS)
	_cached_images[Placement.ROT_0] = image

func get_texture() -> Texture2D:
	return _texture

func get_image(placement := Placement.ROT_0) -> Image:
	if not is_placement_valid(placement):
		push_warning("Placement '%d' is invalid" % placement)
		return _cached_images[Placement.ROT_0]
	if _cached_images[placement] != null:
		return _cached_images[placement]
	var image := _cached_images[Placement.ROT_0].duplicate()
	if is_placement_flipped(placement):
		image.flip_x()
	match placement:
		Placement.ROT_90, Placement.FLIP_ROT_0:
			image.rotate_90(CLOCKWISE)
		Placement.ROT_180, Placement.FLIP_ROT_180:
			image.rotate_180()
		Placement.ROT_270, Placement.FLIP_ROT_270:
			image.rotate_90(COUNTERCLOCKWISE)
	_cached_images[placement] = image
	return image
