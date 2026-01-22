@tool
class_name PipBar extends TextureProgressBar

const BORDER_COLOR := Color.WHITE
const BORDER_WIDTH := 2.0
const PIP_WIDTH_SCALE_SMALL := 0.5
const PIP_WIDTH_SCALE_LARGE := 1.0

@export var increment_small := 100.0
@export var increment_large := 1000.0
@export var threshold := 1000.0

func get_increment() -> float:
	return increment_large if max_value > threshold else increment_small

func get_pip_scale() -> float:
	return PIP_WIDTH_SCALE_LARGE if max_value > threshold else PIP_WIDTH_SCALE_SMALL

func _draw() -> void:
	var pip_width := size.y * get_pip_scale()
	var num_pips := max_value / get_increment()
	# NOTE: Size is not fixed (ensure your UI can dynamically resize too)
	custom_minimum_size.x = pip_width * num_pips
	# Draw equally sized rectangles for pips
	for i in roundi(num_pips):
		var rect := Rect2(i * pip_width, 0.0, pip_width, size.y)
		draw_rect(rect, BORDER_COLOR, false, BORDER_WIDTH)
