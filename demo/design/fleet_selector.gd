extends OptionButton

const NEW_FLEET_OPTION := "NEW FLEET"

@export var capital_ship: Node2D
@export var ships: Array[Node2D]
@export var turrets: Array[Node2D]

var ship_manager := ShipManager.new()

func _on_item_selected(index):
	if get_item_text(index) == NEW_FLEET_OPTION:
		# TODO: notify ShipManager
		print("Trying to make a new fleet...")

func _on_delete_fleet_button_down():
	var fleet_name := get_item_text(selected)
	if fleet_name != NEW_FLEET_OPTION:
		remove_item(selected)
		# TODO: notify ShipManager
