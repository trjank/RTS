class_name FleetContainer extends PanelContainer

signal fleet_changed(new_fleet: Fleet)
signal button_pressed(slot: int)
signal pressed(fleet: Fleet)
signal delete_requested(fleet: Fleet)

const MINI_ICONS: Dictionary[int, Texture] = {
	Fleet.CAPITAL_SHIP_SLOT: preload("res://icons/capital_ship.png")
}

@export var button_size := Vector2(250.0, 250.0)
@export var fleet_id: Label
@export var name_edit: LineEdit
@export var ship_buttons: Container

var fleet: Fleet:
	set = set_fleet

static func create() -> FleetContainer:
	return preload("res://ships_screen/fleet_container.tscn").instantiate()

func _ready() -> void:
	update_ui()
	_add_fleet_ships()

func get_button(slot: int) -> ShipButton:
	return ship_buttons.get_child(slot) as ShipButton

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	if fleet != null:
		_disconnect_old_fleet(fleet)
	if new_fleet != null:
		_connect_new_fleet(new_fleet)
	fleet = new_fleet
	update_ui()
	_add_fleet_ships()
	fleet_changed.emit(fleet)

func _add_fleet_ships() -> void:
	if not is_node_ready():
		return
	for child in ship_buttons.get_children():
		child.queue_free()
	if fleet != null:
		fleet.for_each_ship(_add_ship)

func _disconnect_old_fleet(old_fleet: Fleet) -> void:
	old_fleet.ui_update.disconnect(update_ui)
	old_fleet.resized.disconnect(_add_fleet_ships)
	old_fleet.ship_changed.disconnect(_on_fleet_ship_changed)

func _connect_new_fleet(new_fleet: Fleet) -> void:
	new_fleet.ui_update.connect(update_ui)
	new_fleet.resized.connect(_add_fleet_ships)
	new_fleet.ship_changed.connect(_on_fleet_ship_changed)

func update_ui() -> void:
	if not is_node_ready():
		return
	if fleet == null:
		_clear_ui()
	else:
		_create_fleet_ui()

func _create_fleet_ui() -> void:
	fleet_id.text = "Fleet #%d" % fleet.get_id()
	name_edit.text = fleet.name
	name_edit.editable = true

func _clear_ui() -> void:
	fleet_id.text = ""
	name_edit.text = ""
	name_edit.editable = false

func _update_slot(new_ship: ShipData, slot: int) -> bool:
	return fleet.set_ship(slot, new_ship) and fleet.save_ships()

func _add_ship(ship: ShipData, slot: int) -> void:
	var button := ShipButton.create()
	button.ship = ship
	button.in_fleet = true
	button.mini_icon = MINI_ICONS.get(slot)
	# NOTE: Updating button_size does not automatically resize all the buttons
	button.custom_minimum_size = button_size
	button.ship_changed.connect(_update_slot.bind(slot) )
	button.pressed.connect(button_pressed.emit.bind(slot) )
	ship_buttons.add_child(button)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		pressed.emit(fleet)

func _on_delete_fleet_pressed() -> void:
	delete_requested.emit(fleet)

func _on_name_focus_exited() -> void:
	_on_name_text_submitted(name_edit.text)

func _on_name_text_submitted(new_text: String) -> bool:
	return fleet.set_name(new_text) and fleet.save_metadata()

func _on_fleet_swap_button_pressed() -> void:
	globals.main.state = Main.State.FLEET

func _on_fleet_ship_changed(new_ship: ShipData, slot: int) -> void:
	get_button(slot).ship = new_ship
