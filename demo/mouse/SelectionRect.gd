extends CollisionShape2D

var color := Color(1.0, 1.0, 1.0, 0.15)

func _draw():
	draw_rect(shape.get_rect(), color)

func resize(size: Vector2)->void:
	shape.size = size
	queue_redraw()
