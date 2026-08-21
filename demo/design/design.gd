class_name Design extends Node

signal slot_changed(new_slot: int)

const SELECTED_COLOR := Color(2.454, 1.027, 1.027, 1.0)
# NOTE: This prefix ensures random text does not destroy the current ship
const SHIP_STRING_PREFIX := "ship"
const SHIP_STRING_DELIMETER := "%"
# NOTE: a 128x128 grid may result in a 4096x4096 px image (so try not to go beyond it)
const SMALL_GRID  := Vector2i(16, 16)
const MEDIUM_GRID := Vector2i(32, 32)
const LARGE_GRID  := Vector2i(64, 64)
const HUGE_GRID   := Vector2i(128, 128)
const GRID_SIZES: Array[Vector2i] = [SMALL_GRID, MEDIUM_GRID, LARGE_GRID, HUGE_GRID]

@export var part_selection: PartSelection
@export var parts_container: PartsContainer
@export var fleet_container: FleetContainer
@export var grid: Grid
@export var stats_box: StatsBox
@export var save_popup: AcceptDialog
@export var export_popup: ExportShipPopup
@export var import_popup: ImportShipPopup
@export var resize_option_button: OptionButton

var slot := -1:
	set = set_slot
var fleet: Fleet:
	set = set_fleet

func _ready() -> void:
	Globals.client.fleet_changed.connect(set_fleet)
	fleet = Globals.client.fleet
	parts_container.part_manager = Globals.part_manager
	slot = 0

func get_ship() -> ShipData:
	return fleet.get_ship(slot)

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	if fleet != null:
		fleet.ship_changed.disconnect(_on_fleet_ship_changed)
	if new_fleet != null:
		new_fleet.ship_changed.connect(_on_fleet_ship_changed)
	fleet = new_fleet
	fleet_container.fleet = fleet
	grid.clear_cache()

func set_slot(new_slot: int) -> void:
	new_slot = clampi(new_slot, 0, fleet.size)
	if slot == new_slot:
		return
	fleet_container.get_button(slot).self_modulate = Color.WHITE
	fleet_container.get_button(new_slot).self_modulate = SELECTED_COLOR
	slot = new_slot
	grid.ship = get_ship()
	grid.cache()
	stats_box.ship = get_ship()
	slot_changed.emit(slot)

func save() -> void:
	part_selection.move_parts()
	var error_flags := grid.save()
	if error_flags != ShipData.PartError.OK or not grid.ship.are_parts_connected():
		return popup_error_message(error_flags)
	grid.ship.generate_image()
	grid.ship.calculate_stats()
	grid.ship.save()

func popup_error_message(error_flags: int) -> void:
	var error_message := "Failed to save for the following reasons:\n\n"
	if error_flags & ShipData.PartError.IS_NULL:
		error_message += "NULL part (PLEASE REPORT THIS BUG)\n"
	if error_flags & ShipData.PartError.OUT_OF_BOUNDS:
		error_message += "Part is out of bounds\n"
	if error_flags & ShipData.PartError.OVERLAP:
		error_message += "Parts are overlapping\n"
	elif not grid.ship.are_parts_connected():
		error_message += "Parts are disconnected (%d clusters detected)\n" % grid.ship.count_part_clusters()
	save_popup.dialog_text = error_message
	save_popup.show()

func _create_new_ship() -> bool:
	var ship := ShipData.new()
	ship.grid_size = SMALL_GRID
	Globals.ship_db.create_ship(ship)
	return fleet.set_ship(slot, ship) and fleet.save_ships()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()
	if event.is_action_pressed("undo"):
		part_selection.delete_parts()
		grid.sync()

func _on_grid_save_changed(ship: ShipData, saved: bool) -> void:
	var ship_slot := fleet._ships.find(ship)
	fleet_container.get_button(ship_slot).saved = saved

func _on_parts_container_part_clicked(part_data: PartData) -> void:
	if fleet == null:
		return
	if get_ship() == null:
		_create_new_ship()
	part_selection.spawn_part_at_mouse(part_data)
	part_selection.begin_dragging()

func _on_fleet_ship_changed(new_ship: ShipData, which_slot: int) -> void:
	if slot != which_slot:
		return
	grid.ship = new_ship
	grid.cache()
	stats_box.ship = new_ship

func convert_ship_to_string(ship_data := grid.ship) -> String:
	if ship_data == null:
		return ""
	var size_str := str(ship_data.grid_size.x) + SHIP_STRING_DELIMETER + str(ship_data.grid_size.y)
	var byte_str := Marshalls.raw_to_base64(ship_data.serialize() )
	return SHIP_STRING_PREFIX + SHIP_STRING_DELIMETER + size_str + SHIP_STRING_DELIMETER + byte_str

func load_ship_from_string(ship_string: String) -> int:
	var split := ship_string.split(SHIP_STRING_DELIMETER)
	if split.size() != 4 or split[0] != SHIP_STRING_PREFIX:
		return ShipData.PartError.INCORRECT_SIZE_BYTES
	var bytes := Marshalls.base64_to_raw(split[3] )
	grid.ship.grid_size = Vector2i(int(split[1] ), int(split[2] ) )
	var error := grid.ship.deserialize(bytes, Globals.part_manager)
	grid.sync(false)
	return error

func _on_fleet_container_button_pressed(new_slot: int) -> void:
	slot = new_slot

func _on_behavior_swap_button_pressed() -> void:
	Globals.main.state = Main.State.UNIT_LOGIC_EDITOR

func _on_test_button_pressed() -> void:
	Globals.main.state = Main.State.TRAINING_GROUNDS

func _on_export_button_pressed() -> void:
	export_popup.ship_string = convert_ship_to_string()
	import_popup.hide()
	export_popup.show()

func _on_import_button_pressed() -> void:
	export_popup.hide()
	import_popup.show()

func _on_resize_option_button_item_selected(index: int) -> void:
	grid.ship.grid_size = GRID_SIZES[index]
	grid.force_recalculate_error()

func _on_grid_ship_changed(_grid: Grid) -> void:
	resize_option_button.selected = GRID_SIZES.find(grid.ship.grid_size) if grid.ship != null else 0

func _on_import_ship_popup_requested_import(ship_string: String) -> void:
	load_ship_from_string(ship_string)
