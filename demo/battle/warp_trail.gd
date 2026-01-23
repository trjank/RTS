class_name WarpTrail extends Line2D

const FADE_TIME_SEC := 1.0

static func create() -> WarpTrail:
	return preload("res://battle/warp_trail.tscn").instantiate()

func _ready() -> void:
	create_tween().tween_property(self, "modulate:a", 0.0, FADE_TIME_SEC)

func _on_death_timer_timeout() -> void:
	queue_free()
