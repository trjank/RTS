class_name PartsContainer extends PanelContainer

signal part_clicked(part_data: PartData)

@export var tabs: Dictionary[String, HFlowContainer]

static func part_sorter(a: PartData, b: PartData) -> bool:
	return a.get_width() < b.get_width() or (a.get_width() == b.get_width() and a.name < b.name)

func _ready() -> void:
	PartManager.part_created.connect(add_part)
	print("(PartsContainer) Problematic parts: ", reset_parts() )

func clear() -> bool:
	return tabs.keys().all(clear_tab)

func clear_tab(tab: String) -> bool:
	if not tab in tabs:
		return false
	for part in tabs[tab].get_children():
		part.queue_free()
	return true

## Returns list of parts that failed to load
func reset_parts() -> Array:
	var parts := PartManager.get_parts()
	parts.sort_custom(part_sorter)
	clear()
	return parts.filter(func (part: PartData) -> bool: return not add_part(part) )

func add_part(part_data: PartData) -> bool:
	if part_data == null or not part_data.tab in tabs:
		return false
	var container := tabs[part_data.tab]
	var button := PartButton.create()
	button.part_data = part_data
	button.button_down.connect(part_clicked.emit.bind(part_data) )
	container.add_child(button)
	return true
