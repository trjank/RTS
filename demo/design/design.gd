class_name Design extends Node

signal slot_changed(new_slot: int)

const SELECTED_COLOR := Color(2.454, 1.027, 1.027, 1.0)
const STANDARD_SHIP_SIZE := Vector2i(16, 16)

@export var part_group: PartGroup
@export var parts_container: PartsContainer
@export var fleet_container: FleetContainer
@export var mouse_selection: MouseSelection
@export var grid: Grid
@export var save_popup: AcceptDialog

var slot := -1:
	set = set_slot
var fleet: Fleet:
	set = set_fleet

func _ready() -> void:
	part_group.dragging_started.connect(mouse_selection.disable)
	part_group.dragging_ended.connect(mouse_selection.enable)
	mouse_selection.selected.connect(part_group.select)
	globals.client.fleet_changed.connect(set_fleet)
	fleet = globals.client.fleet
	parts_container.part_manager = globals.part_manager
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
	slot_changed.emit(slot)

func save() -> void:
	part_group.move_parts()
	var error_flags := grid.save()
	if error_flags == ShipData.PartError.OK:
		grid.ship.generate_image()
		grid.ship.save()
	else:
		popup_error_message(error_flags)

func popup_error_message(error_flags: int) -> void:
	var error_message := "Failed to save for the following reasons:\n\n"
	if error_flags & ShipData.PartError.IS_NULL:
		error_message += "☐ NULL part (PLEASE REPORT THIS BUG)\n"
	if error_flags & ShipData.PartError.OUT_OF_BOUNDS:
		error_message += "☐ Part is out of bounds\n"
	if error_flags & ShipData.PartError.OVERLAP:
		error_message += "☐ Parts are overlapping\n"
	elif not grid.ship.are_parts_connected():
		error_message += "☐ Parts are disconnected (%d clusters detected)\n" % grid.ship_data.count_part_clusters()
	save_popup.dialog_text = error_message
	save_popup.show()

func _create_new_ship() -> bool:
	var ship := ShipData.new()
	ship.grid_size = STANDARD_SHIP_SIZE
	globals.ship_db.create_ship(ship)
	return fleet.set_ship(slot, ship) and fleet.save_ships()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()

func _on_grid_save_changed(ship: ShipData, saved: bool) -> void:
	var ship_slot := fleet._ships.find(ship)
	fleet_container.get_button(ship_slot).saved = saved

func _on_parts_container_part_clicked(part_data: PartData) -> void:
	if fleet == null:
		return
	if get_ship() == null:
		_create_new_ship()
	part_group.spawn_part_at_mouse(part_data)
	part_group.begin_dragging()

func _on_fleet_ship_changed(new_ship: ShipData, which_slot: int) -> void:
	if slot == which_slot:
		grid.ship = new_ship
	grid.uncache(new_ship)

func _on_fleet_container_button_pressed(new_slot: int) -> void:
	slot = new_slot
