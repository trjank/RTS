extends Button

func _on_v_box_container_child_order_changed() -> void:
	get_parent().move_to_front.call_deferred()
