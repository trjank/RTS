class_name ShipsScreen extends Node

signal fleet_changed(new_fleet: FleetID)

const BUTTON_SIZE := Vector2(250.0, 250.0)

@export var ships_box: HFlowContainer
@export var fleets_box: VBoxContainer
@export var create_ship_button: Button
@export var delete_ship_box: TextureRect

var fleet: FleetID:
	set = set_fleet
var ship_db: ShipDatabase:
	set = set_ship_db

var _ship_buttons: Dictionary[ShipDataID, ShipButton] = {}
var _editable_fleets: Dictionary[FleetID, EditableFleetContainer] = {}

func _ready() -> void:
	ship_db = globals.ship_db

func set_ship_db(new_ship_db: ShipDatabase) -> void:
	ship_db = new_ship_db
	load_ships_and_fleets()

func set_fleet(new_fleet: FleetID) -> void:
	if fleet == new_fleet:
		return
	globals.client.fleet = new_fleet
	fleet = new_fleet
	fleet_changed.emit(fleet)

func clear() -> void:
	for ship_button in _ship_buttons.values():
		ship_button.queue_free()
	for editable_fleet in _editable_fleets.values():
		editable_fleet.queue_free()
	_ship_buttons.clear()
	_editable_fleets.clear()

func load_ships_and_fleets() -> void:
	clear()
	if ship_db == null:
		return
	for new_ship in ship_db.get_loaded_ships():
		load_ship(new_ship)
	for new_fleet in ship_db.get_loaded_fleets():
		load_fleet(new_fleet)

func _reorder_children() -> void:
	# NOTE: This orders the ships to be BEFORE these nodes
	create_ship_button.move_to_front()
	delete_ship_box.move_to_front()

func load_ship(new_ship: ShipDataID) -> void:
	if new_ship in _ship_buttons:
		return
	var button := ShipButton.create()
	button.custom_minimum_size = BUTTON_SIZE
	button.ship = new_ship
	ships_box.add_child(button)
	_reorder_children()
	_ship_buttons[new_ship] = button

func load_fleet(new_fleet: FleetID) -> void:
	if new_fleet in _editable_fleets:
		return
	var editable_fleet := EditableFleetContainer.create()
	editable_fleet.fleet = new_fleet
	editable_fleet.selected.connect(set_fleet)
	editable_fleet.delete_requested.connect(delete_fleet)
	fleet_changed.connect(editable_fleet._on_fleet_changed)
	fleets_box.add_child(editable_fleet)
	_editable_fleets[new_fleet] = editable_fleet

func delete_ship(old_ship: ShipDataID) -> bool:
	if not old_ship in _ship_buttons:
		return false
	# NOTE: This deletion is permanent (BE CAREFUL)
	_ship_buttons[old_ship].queue_free()
	_ship_buttons.erase(old_ship)
	return ship_db.delete_ship(old_ship)

func delete_fleet(old_fleet: FleetID) -> bool:
	if not old_fleet in _editable_fleets:
		return false
	# NOTE: This deletion is permanent (BE CAREFUL)
	_editable_fleets[old_fleet].queue_free()
	_editable_fleets.erase(old_fleet)
	return ship_db.delete_fleet(old_fleet)

func _on_create_ship_button_pressed() -> void:
	var new_ship_data := ShipData.new(32, 32)
	var new_ship := ship_db.create_ship(new_ship_data)
	load_ship(new_ship)

func _on_create_fleet_button_pressed() -> void:
	var new_fleet := ship_db.create_fleet(Fleet.new() )
	load_fleet(new_fleet)

func _on_delete_ship_delete_requested(ship: ShipDataID) -> void:
	delete_ship(ship)
