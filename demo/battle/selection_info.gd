extends GridContainer

@export var count_label: Label

func _on_mouse_selection_selected(bodies: Array[Node3D], _center: Vector3, _span: Vector2) -> void:
	visible = not bodies.is_empty()
	count_label.text = str(bodies.size() )
