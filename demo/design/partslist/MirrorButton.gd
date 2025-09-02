extends TextureButton

signal mirror_mode_changed

@export var mirror_axis: Line2D
@export var grid: Sprite2D

var mirror_mode := false
var mirror_enabled_image := preload("res://icons/mirror_mode_enabled.png")
var mirror_disabled_image := preload("res://icons/mirror_mode_disabled.png")

func _unhandled_input(event: InputEvent)->void:
	if event.is_action_pressed("mirror mode"):
		_on_button_down()
	var dx := PartData.PX_PER_GRID_SQUARE * Input.get_axis("move mirror left", "move mirror right")
	var max_x := grid.region_rect.size.x
	mirror_axis.position.x = clampf(mirror_axis.position.x + dx, 0, max_x)

func _on_button_down()->void:
	mirror_mode = not mirror_mode
	mirror_axis.visible = mirror_mode
	texture_normal = mirror_enabled_image if mirror_mode else mirror_disabled_image
	mirror_mode_changed.emit()
