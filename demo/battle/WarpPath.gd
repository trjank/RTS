extends Line2D

const LIFESPAN_SEC := 1.0

func _ready() -> void:
	# Free the node after some time to conserve memory
	var death_timer := Timer.new()
	add_child(death_timer, false, Node.INTERNAL_MODE_FRONT)
	death_timer.one_shot = true
	death_timer.timeout.connect(queue_free)
	death_timer.start(LIFESPAN_SEC)
	# Make the path slowly fade out so the queue_free is seamless
	create_tween().tween_property(self, "modulate:a", 0.0, LIFESPAN_SEC)
