class_name PartButton extends TextureButton

var part_data: PartData:
	set = set_part_data

static func create() -> PartButton:
	return preload("res://design/part_button.tscn").instantiate() as PartButton

func _ready() -> void:
	update_ui()

func set_part_data(new_part_data: PartData) -> void:
	if part_data != null:
		part_data.image_changed.disconnect(update_ui)
	if new_part_data != null:
		new_part_data.image_changed.connect(update_ui)
	part_data = new_part_data
	update_ui()

func update_ui() -> void:
	if part_data == null or not is_node_ready():
		return
	texture_normal = part_data.image.get_texture()
	custom_minimum_size = Measurement.PX_PER_TILE * part_data.get_size()
