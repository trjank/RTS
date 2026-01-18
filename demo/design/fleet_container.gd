class_name FleetContainer extends PanelContainer

signal slot_clicked(slot: int)

@export var ship_buttons: VBoxContainer
@export var fleet_name: Label

var fleet: Fleet:
	set = set_fleet

func get_button(slot: int) -> ShipButton:
	return ship_buttons.get_child(slot) as ShipButton

func set_fleet(new_fleet: Fleet) -> void:
	_clear()
	if fleet != null:
		fleet.ship_changed.disconnect(_on_fleet_ship_changed)
		fleet.renamed.disconnect(rename)
	if new_fleet != null:
		rename(new_fleet.name)
		new_fleet.for_each_ship(_add_ship)
		new_fleet.ship_changed.connect(_on_fleet_ship_changed)
		new_fleet.renamed.connect(rename)
	fleet = new_fleet

func _clear() -> void:
	for child in ship_buttons.get_children():
		child.queue_free()

func _add_ship(ship: ShipDataID, slot: int) -> void:
	var button := ShipButton.create()
	button.ship = ship
	button.pressed.connect(slot_clicked.emit.bind(slot) )
	ship_buttons.add_child(button)

func rename(new_name: String) -> void:
	fleet_name.text = new_name

func _on_fleet_ship_changed(slot: int, new_ship: ShipDataID) -> void:
	get_button(slot).ship_data = new_ship.ship_data

func _on_design_save_changed(slot: int, saved: bool) -> void:
	get_button(slot).unsaved_indicator.visible = saved

func _on_fleet_swap_button_pressed() -> void:
	globals.main.state = Main.State.FLEET
