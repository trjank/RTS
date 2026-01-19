extends Button

func _on_grid_container_child_order_changed() -> void:
	move_to_front.call_deferred()
