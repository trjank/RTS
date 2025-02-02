extends ColorRect

var dragging := false
var enabled := true
var selected := []
var mouse_start_position: Vector2

func reset():
	size = Vector2.ZERO

func resize():
	var mouse_position = get_global_mouse_position()
	position.x = min(mouse_start_position.x, mouse_position.x)
	position.y = min(mouse_start_position.y, mouse_position.y)
	size = abs(mouse_position - mouse_start_position)

func deselect(node):
	if not (node in selected): return
	node.on_deselect()
	selected.erase(node)

func select(node):
	# Prevent duplication
	if node in selected: return
	node.on_select()
	selected.append(node)

func deselect_all():
	# Loop backwards through array for deletion
	for index in range(selected.size() - 1, -1, -1):
		deselect(selected[index])

func select_all():
	var selectable_nodes = get_tree().get_nodes_in_group("selectable")
	for node in selectable_nodes:
		if get_rect().intersects(node.bounding_box):
			select(node)

func _process(_delta):
	if enabled and dragging: resize()

func _unhandled_input(_event):
	if not enabled: return
	if Input.is_action_just_pressed("left_click"):
		# Start up a new selection
		mouse_start_position = get_global_mouse_position()
		dragging = true
	if dragging and Input.is_action_just_released("left_click"):
		# End the current selection
		dragging = false
		deselect_all()
		select_all()
		reset()
