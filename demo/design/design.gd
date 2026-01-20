class_name Design extends Node

signal slot_changed(new_slot: int)
signal save_changed(ship_slot: int, saved: bool)

@export var part_group: PartGroup
@export var parts_container: PartsContainer
@export var fleet_container: FleetContainer
@export var mouse_selection: MouseSelection
@export var grid: Grid
@export var save_popup: AcceptDialog

var slot := 0:
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

func get_ship() -> ShipData:
	return fleet.get_ship(slot)

func set_fleet(new_fleet: Fleet) -> void:
	if fleet == new_fleet:
		return
	fleet = new_fleet
	fleet_container.fleet = fleet
	grid.clear_cache()

func set_slot(new_slot: int) -> void:
	new_slot = clampi(new_slot, 0, fleet.fleet.size() )
	if slot == new_slot:
		return
	slot = new_slot
	grid.ship_data = get_ship().ship_data
	grid.cache()
	slot_changed.emit(slot)

func save() -> void:
	var moved_parts := part_group.move_parts()
	assert(moved_parts)
	var error_flags := grid.save()
	if error_flags == ShipData.PartError.OK:
		return grid.ship_data.generate_image()
	var error_message := "Failed to save for the following reasons:\n\n"
	if error_flags & ShipData.PartError.IS_NULL:
		error_message += "☐ NULL part (PLEASE REPORT THIS BUG)\n"
	if error_flags & ShipData.PartError.OUT_OF_BOUNDS:
		error_message += "☐ Part is out of bounds\n"
	if error_flags & ShipData.PartError.OVERLAP:
		error_message += "☐ Parts are overlapping\n"
	if not grid.ship_data.are_parts_connected():
		error_message += "☐ Parts are disconnected (%d clusters detected)\n" % grid.ship_data.count_part_clusters()
	save_popup.dialog_text = error_message
	save_popup.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save()

func _on_grid_save_changed(saved: bool) -> void:
	save_changed.emit(slot, saved)

func _on_parts_container_part_clicked(part_data: PartData) -> void:
	part_group.spawn_part_at_mouse(part_data)
	part_group.begin_dragging()
