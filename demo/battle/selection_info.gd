extends GridContainer

@export var count_label: Label

func _ready() -> void:
	visible = false

func _on_mouse_selection_selected(nodes: Array[Node3D], _center: Vector3, _span: Vector2) -> void:
	visible = not nodes.is_empty()
	count_label.text = str(nodes.size() )
