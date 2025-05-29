extends OptionButton

@export var part_tabs_container: TabContainer

func _ready():
	item_selected.connect(on_item_selected)

func on_item_selected(item_id):
	part_tabs_container.current_tab = item_id
