@tool
class_name PipBar extends MeshInstance3D

const MIN_PIP_COUNT := 1
const MIN_BORDER_WIDTH := 0.0
const MAX_BORDER_WIDTH := 1.0

@export var border_width := 0.1:
	set = set_border_width
@export var size := Vector2.ONE:
	set = set_size
@export var pip_count := 1:
	set = set_pip_count
@export var value := 0.0:
	set = set_value
@export var max_value := 0.0:
	set = set_max_value

func set_value(new_value: float) -> void:
	value = new_value
	_recalculate_pip_progress()

func set_max_value(new_max_value: float) -> void:
	max_value = new_max_value
	_recalculate_pip_progress()

func set_pip_count(new_pip_count: int) -> void:
	pip_count = maxi(new_pip_count, MIN_PIP_COUNT)
	_recalculate_pip_width()

func set_border_width(new_border_width: float) -> void:
	border_width = clampf(new_border_width, MIN_BORDER_WIDTH, MAX_BORDER_WIDTH)
	set_instance_shader_parameter("border_width", border_width)
	_recalculate_pip_width()

func set_size(new_size: Vector2) -> void:
	size = new_size.abs()
	scale = Vector3(new_size.x, 1.0, new_size.y)
	set_instance_shader_parameter("size", size)
	_recalculate_pip_width()

func _recalculate_pip_progress() -> void:
	var pip_progress := clampf(value / max_value, 0.0, 1.0)
	set_instance_shader_parameter("pip_progress", pip_progress)

func _recalculate_pip_width() -> void:
	var pip_width := (size.x - border_width) / pip_count
	set_instance_shader_parameter("pip_width", pip_width)
