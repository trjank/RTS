extends Battle

@export var clock: Timer
@export var clock_minutes_label: Label
@export var clock_seconds_label: Label
@export var overlay: CanvasLayer

const UI_REFRESHES_PER_SEC := 1.0

func hide_overlay()->void:
	overlay.hide()

func show_overlay()->void:
	overlay.show()

func _ready()->void:
	clock.timeout.connect(on_UI_refresh)
	start_countdown()
	on_UI_refresh()
	set_duration_sec(360)
	clock.start(UI_REFRESHES_PER_SEC)

func on_UI_refresh()->void:
	clock_minutes_label.text = "%d"   % get_minutes_left()
	clock_seconds_label.text = "%02d" % get_seconds_left()
