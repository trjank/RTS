class_name PartsContainer extends PanelContainer

signal part_clicked(part_data: PartData)

@export var tabs: Dictionary[String, HFlowContainer]

var part_manager: PartManager:
	set = set_part_manager

static func part_sorter(a: PartData, b: PartData) -> bool:
	return a.get_width() < b.get_width() or (a.get_width() == b.get_width() and a.name < b.name)

func set_part_manager(new_part_manager: PartManager) -> void:
	if part_manager == new_part_manager:
		return
	clear()
	if part_manager != null:
		part_manager.part_created.disconnect(_add_part)
	if new_part_manager != null:
		_add_parts(new_part_manager)
		new_part_manager.part_created.connect(_add_part)
	part_manager = new_part_manager

func clear_tab(tab: String) -> void:
	if not tab in tabs:
		return push_error("Tab '%s' does not exist" % tab)
	for node in tabs[tab].get_children():
		_remove_part(node)

func clear() -> void:
	for tab in tabs:
		clear_tab(tab)

func _remove_part(node: Node) -> void:
	if node is PartButton:
		node.queue_free()

func _add_parts(new_part_manager: PartManager) -> void:
	var parts := new_part_manager.get_parts()
	parts.sort_custom(part_sorter)
	#
	for part in parts:
		_add_part(part)

func _add_part(part_data: PartData) -> void:
	if not part_data.tab in tabs:
		return push_error("Tab '%s' does not exist" % part_data.tab)
	var container := tabs[part_data.tab]
	var button := PartButton.create()
	button.part_data = part_data
	button.button_down.connect(part_clicked.emit.bind(part_data) )
	container.add_child(button)
