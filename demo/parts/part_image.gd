class_name PartImage extends RefCounted

const FORMAT := Image.FORMAT_RGBA8
const NORMAL_MAP_FORMAT := Image.FORMAT_RGTC_RG
const FOLDER_PATHS := [
	"res://part_images/",
	"res://part_normal_maps/",
	"user://part_images/",
	"user://part_normal_maps/"
]
const IMAGE_NOT_FOUND := preload("res://icons/image_not_found.png")
const TEXTURE_NOT_FOUND := preload("res://icons/texture_not_found.png")

var _texture: Texture2D
var _cached_images: Array[Image] = []

static func is_in_folder(folder: String, path: String) -> bool:
	return path.begins_with(folder)

func _init(path: String, tiles_wide := 1, tiles_tall := 1) -> void:
	if path.contains("..") or not FOLDER_PATHS.any(is_in_folder.bind(path) ):
		push_error("PartImage path '%s' is invalid" % path)
	else:
		_texture = load(path) as Texture2D
	if _texture == null:
		_texture = TEXTURE_NOT_FOUND
	var image := _texture.get_image()
	image.convert(FORMAT)
	image.resize(Grid.PX_PER_TILE * tiles_wide, Grid.PX_PER_TILE * tiles_tall)
	_cached_images.resize(Grid.PartPlacement.NUM_PLACEMENTS)
	_cached_images[Grid.PartPlacement.ROT_0] = image

func get_texture() -> Texture2D:
	return _texture

func get_image(placement := Grid.PartPlacement.ROT_0) -> Image:
	if not Grid.is_placement_valid(placement):
		push_error("Placement '%d' is invalid" % placement)
		return _cached_images[Grid.PartPlacement.ROT_0]
	if _cached_images[placement] != null:
		return _cached_images[placement]
	var image := _cached_images[Grid.PartPlacement.ROT_0].duplicate()
	_transform_image(image, placement)
	_cached_images[placement] = image
	return image

func _transform_image(image: Image, placement: Grid.PartPlacement) -> void:
	match placement:
		Grid.PartPlacement.FLIP_ROT_0: image.flip_x()
		Grid.PartPlacement.ROT_90: image.rotate_90(CLOCKWISE)
		Grid.PartPlacement.FLIP_ROT_90: image.flip_x(); image.rotate_90(CLOCKWISE)
		Grid.PartPlacement.ROT_180: image.rotate_180()
		Grid.PartPlacement.FLIP_ROT_180: image.flip_x(); image.rotate_180()
		Grid.PartPlacement.ROT_270: image.rotate_90(COUNTERCLOCKWISE)
		Grid.PartPlacement.FLIP_ROT_270: image.flip_x(); image.rotate_90(COUNTERCLOCKWISE)
