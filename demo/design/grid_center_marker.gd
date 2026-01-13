extends Sprite2D

func _on_grid_ship_changed(grid: Grid) -> void:
	position = grid.get_rect().get_center()
