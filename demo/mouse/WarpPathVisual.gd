extends Line2D

const LIFESPAN := 1.0

func set_start(new_start: Vector2)->void:
	points[0] = new_start

func set_end(new_end: Vector2)->void:
	points[1] = new_end

func _on_timer_timeout()->void:
	queue_free()

func _ready()->void:
	var death_timer := Timer.new()
	add_child(death_timer)
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_timer_timeout)
	death_timer.start(LIFESPAN)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, LIFESPAN)
