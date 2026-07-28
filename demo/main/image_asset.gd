class_name ImageAsset extends RefCounted

const IMAGE_FORMAT := Image.FORMAT_RGBA8
const TEXTURE_NOT_FOUND: Texture2D = preload("res://icons/texture_not_found.png")

static var NOT_FOUND := ImageAsset.new(TEXTURE_NOT_FOUND):
	set(__): push_error("(ImageAsset) ImageAsset.NOT_FOUND is immutable!")

static var _assets: Dictionary[String, ImageAsset] = {}

var _path := ""
var _texture: Texture2D
var _image_cache: Array[Image] = []

static func count_assets() -> int:
	return _assets.size()

static func blank_image(size: Vector2i, use_mipmaps := false) -> Image:
	return Image.create_empty(size.x, size.y, use_mipmaps, IMAGE_FORMAT)

static func is_path_valid(path: String) -> bool:
	return not path.contains("..") and (path.begins_with("res://") or path.begins_with("user://") )

static func use(path: String) -> ImageAsset:
	path = path.simplify_path()
	if not is_path_valid(path):
		return NOT_FOUND
	if path in _assets:
		return _assets[path]
	var texture := load(path) as Texture2D
	return ImageAsset.new(texture).register_path(path) if texture != null else NOT_FOUND

func _init(const_texture: Texture2D) -> void:
	assert(const_texture != null)
	#
	_texture = const_texture
	var image := const_texture.get_image()
	image.decompress()
	image.convert(IMAGE_FORMAT)
	_image_cache.resize(Rotation.NUM_DISCRETE_STATES)
	_image_cache[Rotation.Discrete.ROT_0] = image

func is_empty() -> bool:
	return _image_cache[Rotation.Discrete.ROT_0] == null

func get_path() -> String:
	return _path

func get_size() -> Vector2i:
	return _image_cache[Rotation.Discrete.ROT_0].get_size() if not is_empty() else Vector2i.ZERO

func get_texture() -> Texture2D:
	return _texture

func get_image(rotation := Rotation.Discrete.ROT_0) -> Image:
	rotation = Rotation.to_valid(rotation)
	#
	if _image_cache[rotation] != null or is_empty():
		return _image_cache[rotation]
	var image := _transform_image(_image_cache[Rotation.Discrete.ROT_0], rotation)
	_image_cache[rotation] = image
	return image

## This allows the ImageAsset to be retrieved with ImageAsset.use
func register_path(asset_path: String) -> ImageAsset:
	_path = asset_path
	_assets[asset_path] = self
	return self

func _transform_image(image: Image, rotation: Rotation.Discrete) -> Image:
	var copy := image.duplicate()
	#
	if Rotation.is_flip_h(rotation):
		copy.flip_x()
	match Rotation.to_quadrant(rotation):
		1: copy.rotate_90(COUNTERCLOCKWISE)
		2: copy.rotate_180()
		3: copy.rotate_90(CLOCKWISE)
	return copy
