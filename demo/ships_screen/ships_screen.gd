class_name ShipsScreen extends Node

const BUTTON_SIZE := Vector2(300.0, 300.0)

@export var ships_box: HFlowContainer
@export var fleets_box: VBoxContainer

var ship_db: ShipDatabase:
	set = set_ship_db

var _ship_buttons: Dictionary[ShipDataID, ShipButton] = {}
var _editable_fleets: Dictionary[FleetID, EditableFleetContainer] = {}

func _ready() -> void:
	ship_db = globals.ship_db

func set_ship_db(new_ship_db: ShipDatabase) -> void:
	ship_db = new_ship_db
	load_ships_and_fleets()

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
	for ship in ship_db.get_loaded_ships():
		load_ship(ship)
	for fleet in ship_db.get_loaded_fleets():
		load_fleet(fleet)

func load_ship(ship: ShipDataID) -> void:
	if ship in _ship_buttons:
		return
	var button := ShipButton.create()
	button.custom_minimum_size = BUTTON_SIZE
	button.ship = ship
	ships_box.add_child(button)
	_ship_buttons[ship] = button

func load_fleet(fleet: FleetID) -> void:
	if fleet in _editable_fleets:
		return
	var editable_fleet := EditableFleetContainer.create()
	editable_fleet.fleet = fleet
	fleets_box.add_child(editable_fleet)
	_editable_fleets[fleet] = editable_fleet

func delete_ship(ship: ShipDataID) -> bool:
	if not ship in _ship_buttons:
		return false
	# NOTE: This deletion is permanent (BE CAREFUL)
	_ship_buttons[ship].queue_free()
	_ship_buttons.erase(ship)
	return ship_db.delete_ship(ship)

func delete_fleet(fleet: FleetID) -> bool:
	if not fleet in _editable_fleets:
		return false
	# NOTE: This deletion is permanent (BE CAREFUL)
	_editable_fleets[fleet].queue_free()
	_editable_fleets.erase(fleet)
	return ship_db.delete_fleet(fleet)

func _on_create_ship_button_pressed() -> void:
	var new_ship_data := ShipData.new(32, 32)
	var new_ship := ship_db.create_ship(new_ship_data)
	load_ship(new_ship)

func _on_create_fleet_button_pressed() -> void:
	var new_fleet := ship_db.create_fleet(Fleet.new() )
	load_fleet(new_fleet)
