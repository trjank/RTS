@tool
class_name ResizeableSprite2D extends Sprite2D

@export var size := Vector2.ZERO:
	set = set_size

func _init() -> void:
	texture_changed.connect(rescale)

func set_size(new_size: Vector2) -> void:
	size = new_size
	rescale()

func rescale() -> void:
	scale = size / get_rect().size
