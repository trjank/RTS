extends Timer

@export var clock_label: RichTextLabel

func _process(_dt):
	var seconds_left := int(fmod(time_left, 60.0))
	var minutes_left := int(time_left / 60.0)
	var format_str   := "Time | [color='00ed8c']%d[/color]:[color='00ed8c']%02d[/color]"
	clock_label.text  = format_str % [minutes_left, seconds_left]
