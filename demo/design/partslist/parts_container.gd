class_name PartsContainer extends PanelContainer

@export var part_tabs: TabContainer

func add_part(tab: String, part_button: TextureButton) -> bool:
	var container := part_tabs.find_child(tab, false)
	if container == null:
		return false
	container.add_child(part_button)
	return true
