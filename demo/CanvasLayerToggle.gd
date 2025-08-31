extends CanvasLayer

func _on_parent_visibility_changed()->void:
	visible = get_parent().visible

func _ready()->void:
	get_parent().visibility_changed.connect(_on_parent_visibility_changed)
