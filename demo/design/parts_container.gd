class_name PartsContainer extends PanelContainer

signal part_clicked(part_data: PartData)

@export var tabs: Dictionary[String, HFlowContainer]

var part_manager: PartManager:
	set = set_part_manager

func set_part_manager(new_part_manager: PartManager) -> void:
	clear()
	if part_manager != null:
		part_manager.part_created.disconnect(_add_part)
	if new_part_manager != null:
		new_part_manager.for_each_part(_add_part)
		new_part_manager.part_created.connect(_add_part)
	part_manager = new_part_manager

func _remove_part(node: Node) -> void:
	if node is PartButton:
		node.queue_free()

func clear_tab(tab: String) -> void:
	if not tab in tabs:
		return push_error("Tab '%s' does not exist" % tab)
	for node in tabs[tab].get_children():
		_remove_part(node)

func clear() -> void:
	for tab in tabs:
		clear_tab(tab)

func _add_part(part_data: PartData) -> void:
	if not part_data.tab in tabs:
		return push_error("Tab '%s' does not exist" % part_data.tab)
	var container := tabs[part_data.tab]
	var button := PartButton.create()
	button.part_data = part_data
	button.button_down.connect(part_clicked.emit.bind(part_data) )
	container.add_child(button)
