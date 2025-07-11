extends PartGrouping

@export var mirror_axis: Line2D
@export var mirror_button: TextureButton

var mirror: PartGrouping = null

func _on_mouse_selection_selection_ended(selected: Array[Node2D], rect: Rect2)->void:
	select_parts(selected, rect)

func _physics_process(_dt: float)->void:
	if not mirror: return
	# Reposition the mirrored version
	var x_offset      := mirror_axis.position.x - position.x
	mirror.position.x  = mirror_axis.position.x + x_offset
	mirror.position.y  = position.y

func _on_dragging_started()->void:
	if not mirror_button.mirror_mode: return
	# Create a mirrored version
	mirror = clone()
	get_parent().add_child(mirror)
	mirror.scale.x  *= -1
	mirror.rotation *= -1
	parts_flipped.connect(mirror.flip_parts)
	parts_deleted.connect(mirror.delete_parts)
	mirror.parts_deleted.connect(mirror.queue_free)

func _on_dragging_ended()->void:
	if not mirror: return
	# Cleanup the mirrored version
	mirror.snap_to_grid()
	mirror.clear_parts()
	mirror.queue_free()
	mirror = null

func _on_parts_rotated(quarter_turns, duration):
	if mirror: mirror.rotate_parts( -quarter_turns, duration)
