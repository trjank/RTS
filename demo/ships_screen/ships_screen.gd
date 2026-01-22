class_name ShipsScreen extends Node

signal fleet_changed(new_fleet: Fleet)

const BUTTON_SIZE := Vector2(250.0, 250.0)
const SELECTED_COLOR := Color(2.454, 0.813, 0.813, 1.0)

@export var ships_box: HFlowContainer
@export var fleets_box: VBoxContainer
@export var create_ship_button: Button
@export var delete_ship_box: TextureRect

var fleet: Fleet:
	set = set_fleet
var ship_db: ShipDatabase:
	set = set_ship_db

var _ship_buttons: Dictionary[ShipData, ShipButton] = {}
var _fleet_containers: Dictionary[Fleet, FleetContainer] = {}

func _ready() -> void:
	ship_db = globals.ship_db
	fleet = globals.client.fleet

func set_ship_db(new_ship_db: ShipDatabase) -> void:
	ship_db = new_ship_db
	load_ships_and_fleets()

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	if fleet in _fleet_containers:
		_fleet_containers[fleet].self_modulate = Color.WHITE
	if new_fleet in _fleet_containers:
		_fleet_containers[new_fleet].self_modulate = SELECTED_COLOR
	globals.client.fleet = new_fleet
	fleet = new_fleet
	fleet_changed.emit(fleet)

func clear() -> void:
	for ship_button in _ship_buttons.values():
		ship_button.queue_free()
	for fleet_container in _fleet_containers.values():
		fleet_container.queue_free()
	_ship_buttons.clear()
	_fleet_containers.clear()

func load_ships_and_fleets() -> void:
	clear()
	if ship_db == null:
		return
	for new_ship in ship_db.get_loaded_ships():
		load_ship(new_ship)
	for new_fleet in ship_db.get_loaded_fleets():
		load_fleet(new_fleet)

func _reorder_children() -> void:
	# NOTE: This orders the ship buttons to be BEFORE these nodes
	create_ship_button.move_to_front()
	delete_ship_box.move_to_front()

func load_ship(new_ship: ShipData) -> void:
	if new_ship in _ship_buttons:
		return
	var button := ShipButton.create()
	button.custom_minimum_size = BUTTON_SIZE
	button.ship = new_ship
	ships_box.add_child(button)
	_reorder_children()
	_ship_buttons[new_ship] = button

func load_fleet(new_fleet: Fleet) -> void:
	if new_fleet in _fleet_containers:
		return
	var fleet_container := FleetContainer.create()
	fleet_container.fleet = new_fleet
	fleet_container.pressed.connect(set_fleet)
	fleet_container.delete_requested.connect(delete_fleet)
	fleets_box.add_child(fleet_container)
	_fleet_containers[new_fleet] = fleet_container

## NOTE: This deletion is permanent (BE CAREFUL)
func delete_ship(old_ship: ShipData) -> bool:
	if not old_ship in _ship_buttons:
		return false
	_ship_buttons[old_ship].queue_free()
	_ship_buttons.erase(old_ship)
	return ship_db.delete_ship(old_ship)

## NOTE: This deletion is permanent (BE CAREFUL)
func delete_fleet(old_fleet: Fleet) -> bool:
	if not old_fleet in _fleet_containers:
		return false
	_fleet_containers[old_fleet].queue_free()
	_fleet_containers.erase(old_fleet)
	return ship_db.delete_fleet(old_fleet)

func _on_create_ship_button_pressed() -> void:
	var new_ship := ShipData.new()
	new_ship.grid_size = Vector2i(32, 32)
	ship_db.create_ship(new_ship)
	load_ship(new_ship)

func _on_create_fleet_button_pressed() -> void:
	var new_fleet := Fleet.new()
	new_fleet.size = 10
	ship_db.create_fleet(new_fleet)
	load_fleet(new_fleet)

func _on_delete_ship_delete_requested(ship: ShipData) -> void:
	ship.clear()
	delete_ship(ship)
