extends PanelContainer

@onready var part_tabs := %PartTabs

func add_part(tab: String, part_button: PartButton)->void:
	var container := part_tabs.find_child(tab)
	if not container: 
		push_warning("Tab '%s' does not exist" % tab)
	else:
		container.add_child(part_button)
