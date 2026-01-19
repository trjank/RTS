class_name FleetContainer extends PanelContainer

signal slot_clicked(slot: int)

const MINI_ICONS: Dictionary[int, Texture] = {
	Fleet.CAPITAL_SHIP_SLOT: preload("res://icons/flag.png")
}

@export var button_size := Vector2(250.0, 250.0)
@export var ship_buttons: Control
@export var fleet_name: LineEdit

var fleet: FleetID:
	set = set_fleet

var _fleet: Fleet:
	set = _set_fleet

func get_button(slot: int) -> ShipButton:
	return ship_buttons.get_child(slot) as ShipButton

func set_fleet(new_fleet: FleetID) -> void:
	if fleet != null:
		fleet.fleet_changed.disconnect(_set_fleet)
	if new_fleet != null:
		new_fleet.fleet_changed.connect(_set_fleet)
	fleet = new_fleet
	_fleet = fleet.fleet

func _set_fleet(new_fleet: Fleet) -> void:
	for child in ship_buttons.get_children():
		child.queue_free()
	if _fleet != null:
		_disconnect_old_fleet(_fleet)
	if new_fleet != null:
		_connect_new_fleet(new_fleet)
	_fleet = new_fleet

func _disconnect_old_fleet(old_fleet: Fleet) -> void:
	old_fleet.ship_changed.disconnect(_on_fleet_ship_changed)
	old_fleet.renamed.disconnect(_rename)

func _connect_new_fleet(new_fleet: Fleet) -> void:
	_rename(new_fleet.name)
	new_fleet.for_each_ship(_add_ship)
	new_fleet.ship_changed.connect(_on_fleet_ship_changed)
	new_fleet.renamed.connect(_rename)

func _add_ship(ship: ShipDataID, slot: int) -> void:
	var button := ShipButton.create()
	button.ship = ship
	button.in_fleet = true
	button.mini_icon = MINI_ICONS.get(slot)
	button.custom_minimum_size = button_size
	button.pressed.connect(slot_clicked.emit.bind(slot) )
	ship_buttons.add_child(button)

func _rename(new_name: String) -> void:
	fleet_name.text = new_name

func _on_fleet_ship_changed(slot: int, new_ship: ShipDataID) -> void:
	get_button(slot).ship_data = new_ship.ship_data

func _on_design_save_changed(slot: int, saved: bool) -> void:
	get_button(slot).unsaved_indicator.visible = saved

func _on_fleet_swap_button_pressed() -> void:
	globals.main.state = Main.State.FLEET
