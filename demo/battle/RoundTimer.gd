extends Timer

@export var clock_label: RichTextLabel

const TIME_FORMAT_STR := "Time | [color='00ed8c']%d[/color]:[color='00ed8c']%02d[/color]"

func _process(_dt):
	var seconds_left := int(fmod(time_left, 60.0))
	var minutes_left := int(time_left / 60.0)
	clock_label.text  = TIME_FORMAT_STR % [minutes_left, seconds_left]
