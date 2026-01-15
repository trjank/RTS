class_name Design extends Node

signal ship_changed(ship_id: ShipDataID)

@export var part_group: PartGroup
@export var parts_container: PartsContainer
@export var fleets_container: Node
@export var mouse_selection: MouseSelection
@export var grid: Grid
@export var save_popup: AcceptDialog

var parts_manager := PartManager.new()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("save"):
		return
	part_group.move_parts()
	var error_message := ""
	var error_flags := grid.save()
	if error_flags & ShipData.PartError.IS_NULL:
		error_message += "- NULL part (PLEASE REPORT THIS BUG)\n"
	if error_flags & ShipData.PartError.OUT_OF_BOUNDS:
		error_message += "- Part is out of bounds\n"
	if error_flags & ShipData.PartError.OVERLAP:
		error_message += "- Parts are overlapping\n"
	if not grid.ship.are_parts_connected():
		error_message += "- Parts are disconnected (%d clusters detected)\n" % grid.ship.count_part_clusters()
	if error_message != "":
		save_popup.dialog_text = "Failed to save for the following reasons:\n\n" + error_message
		save_popup.show()
	grid.ship.generate_image()
	grid.ship.image.save_png("res://design/cpu_test.png")
	print("image test: ", await Util.benchmark(grid.ship.generate_image))

func _part_clicked(part: PartHitbox) -> void:
	part_group.select_part(part)
	part_group.begin_dragging()

func drag_part(part_data: PartData) -> void:
	part_group.spawn_part_at_mouse(part_data)
	part_group.begin_dragging()

func create_ship_button(_ship: ShipDataID) -> void:
	var button := preload("res://design/ship_button.tscn").instantiate()
	#button.ship_change_requested.connect(select_ship)
	ship_changed.connect(button.show_selected)
	fleets_container.add_child(button)

func create_part_button(part_data: PartData) -> void:
	var button := TextureButton.new()
	button.button_down.connect(drag_part.bind(part_data) )
	button.texture_normal = part_data.get_image().get_texture()
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = Grid.TILE_SIZE * part_data.get_size()
	parts_container.add_part(part_data.tab, button)

func on_global_client_fleet_changed(_new_fleet: FleetID) -> void:
	grid.ship = null

func _ready() -> void:
	part_group.dragging_started.connect(mouse_selection.disable)
	part_group.dragging_ended.connect(mouse_selection.enable)
	mouse_selection.selected.connect(part_group.select)
	globals.client.fleet_changed.connect(on_global_client_fleet_changed)
	var error := parts_manager.load_json(globals.PARTS_JSON_PATH)
	print(PartManager.LoadError.find_key(error))
	for part in parts_manager._parts:
		create_part_button(part)
	parts_manager.generate_atlas()
	parts_manager.atlas.save_png("res://design/atlas_test.png")
