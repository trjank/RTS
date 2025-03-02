extends Battle

@export var clock: Timer
@export var clock_minutes_label: Label
@export var clock_seconds_label: Label

const UI_REFRESH_RATE_SEC := 1.0

var timer: Timer
var seconds: int

func _ready()->void:
	clock.timeout.connect(on_UI_refresh)
	start_countdown()
	on_UI_refresh()
	set_duration_sec(360)
	clock.start(UI_REFRESH_RATE_SEC)

func on_UI_refresh()->void:
	clock_minutes_label.text = str(get_minutes_left())
	clock_seconds_label.text = str(get_seconds_left())
