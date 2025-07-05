extends Timer

@export var clock_minutes_label: Label
@export var clock_seconds_label: Label

func _process(_dt):
	var seconds_left := int(fmod(time_left, 60.0))
	var minutes_left := int(time_left / 60.0)
	clock_minutes_label.text = "%d"   % minutes_left
	clock_seconds_label.text = "%02d" % seconds_left
