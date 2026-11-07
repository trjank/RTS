class_name ShipsScreen extends Node

signal searched_ships(query: String, matches: int)
signal searched_fleets(query: String, matches: int)
signal fleet_changed(new_fleet: Fleet)
signal toggled_ship_names(hidden: bool)

@export var ships_box: HFlowContainer
@export var fleets_box: VBoxContainer
@export var delete_ship_box: TextureRect
@export var load_ships_button: Button
@export var load_fleets_button: Button
#
@export var load_ships_limit := 1
@export var load_fleets_limit := 1
@export var button_size := Vector2(250.0, 250.0)

var fleet: Fleet:
	set = set_fleet
var ship_db: ShipDatabase:
	set = set_ship_db

var _insert_ship_index := -1
var _insert_fleet_index := -1
var _ship_buttons: Dictionary[ShipData, ShipButton] = {}
var _fleet_containers: Dictionary[Fleet, FleetContainer] = {}

func _ready() -> void:
	_insert_ship_index = -ships_box.get_child_count() - 1
	_insert_fleet_index = -fleets_box.get_child_count() - 1
	ship_db = Globals.ship_db
	fleet = Account.me.fleet

func set_ship_db(new_ship_db: ShipDatabase) -> void:
	if new_ship_db == ship_db:
		return
	if ship_db != null:
		_disconnect_signals(ship_db)
	if new_ship_db != null:
		_connect_signals(new_ship_db)
	ship_db = new_ship_db
	load_ships_button.disabled = ship_db == null
	load_fleets_button.disabled = ship_db == null
	load_ships_and_fleets()

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	if fleet in _fleet_containers:
		_fleet_containers[fleet].active = false
	if new_fleet in _fleet_containers:
		_fleet_containers[new_fleet].active = true
	Account.me.fleet = new_fleet
	fleet = new_fleet
	fleet_changed.emit(fleet)

## Returns number of ships that match the search query
func search_ships(query: String) -> int:
	var matches := 0
	for loaded_ship in _ship_buttons:
		matches += 1 if _show_ship(loaded_ship, query) else 0
	return matches

## Returns number of fleets that match the search query
func search_fleets(query: String) -> int:
	var matches := 0
	for loaded_fleet in _fleet_containers:
		matches += 1 if _show_fleet(loaded_fleet, query) else 0
	return matches

func _show_ship(loaded_ship: ShipData, query: String) -> bool:
	var matches_query := ship_matches_search_query(loaded_ship, query)
	_ship_buttons[loaded_ship].visible = matches_query
	return matches_query

func _show_fleet(loaded_fleet: Fleet, query: String) -> bool:
	var matches_query := fleet_matches_search_query(loaded_fleet, query)
	_fleet_containers[loaded_fleet].visible = matches_query
	return matches_query

func ship_matches_search_query(loaded_ship: ShipData, query: String) -> bool:
	return query == "" or loaded_ship.name.begins_with(query) or ("#%d" % loaded_ship.id).begins_with(query)

func fleet_matches_search_query(loaded_fleet: Fleet, query: String) -> bool:
	return query == "" or loaded_fleet.name.begins_with(query) or ("#%d" % loaded_fleet.id).begins_with(query)

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

func _disconnect_signals(old_db: ShipDatabase) -> void:
	old_db.ship_created.disconnect(load_ship)
	old_db.ship_deleted.disconnect(delete_ship)
	old_db.fleet_created.disconnect(load_fleet)
	old_db.fleet_deleted.disconnect(delete_fleet)

func _connect_signals(new_db: ShipDatabase) -> void:
	new_db.ship_created.connect(load_ship)
	new_db.ship_deleted.connect(delete_ship)
	new_db.fleet_created.connect(load_fleet)
	new_db.fleet_deleted.connect(delete_fleet)

func load_ship(new_ship: ShipData) -> void:
	if new_ship in _ship_buttons:
		return
	var button := ShipButton.create()
	button.custom_minimum_size = button_size
	button.ship = new_ship
	toggled_ship_names.connect(button.set_collapsed)
	_ship_buttons[new_ship] = button
	# Assume that new_ship has highest priority and add to the back
	ships_box.add_child(button)
	ships_box.move_child(button, _insert_ship_index)

func load_fleet(new_fleet: Fleet) -> void:
	if new_fleet in _fleet_containers:
		return
	var fleet_container := FleetContainer.create()
	fleet_container.fleet = new_fleet
	fleet_container.pressed.connect(set_fleet)
	fleet_container.delete_requested.connect(delete_fleet)
	_fleet_containers[new_fleet] = fleet_container
	# Assume that new_fleet has highest priority and add to the back
	fleets_box.add_child(fleet_container)
	fleets_box.move_child(fleet_container, _insert_fleet_index)

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

func _on_create_fleet_button_pressed() -> void:
	var new_fleet := Fleet.new()
	new_fleet.size = 10
	ship_db.create_fleet(new_fleet)

func _on_delete_ship_delete_requested(ship: ShipData) -> void:
	ship.clear()
	delete_ship(ship)

func _on_show_ship_names_button_toggled(toggled_on: bool) -> void:
	toggled_ship_names.emit(not toggled_on)

func _on_load_ships_button_pressed() -> void:
	ship_db.load_ships(load_ships_limit)
	searched_ships.emit("", search_ships("") )

func _on_load_fleets_button_pressed() -> void:
	ship_db.load_fleets(load_fleets_limit)
	searched_fleets.emit("", search_fleets("") )

func _on_ship_search_bar_text_submitted(new_text: String) -> void:
	searched_ships.emit(new_text, search_ships(new_text) )

func _on_fleet_search_bar_text_submitted(new_text: String) -> void:
	searched_fleets.emit(new_text, search_fleets(new_text) )
