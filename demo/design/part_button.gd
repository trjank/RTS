class_name PartButton extends TextureButton

static var part_container: PartGrouping

const DISPLAY_SCALE := 1.5 * PartData.PX_PER_GRID_SQUARE

var part_data: PartData

func _ready():
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
	button_down.connect(spawn_part)

func set_display_size(new_display_size: Vector2):
	custom_minimum_size = DISPLAY_SCALE * new_display_size

func spawn_part():
	part_container.spawn_part(part_data)
