@tool
class_name FleetContainer extends PanelContainer

signal fleet_changed(new_fleet: Fleet)
signal button_pressed(slot: int)
signal pressed(which_fleet: Fleet)

const MINI_ICONS: Dictionary[int, Texture] = {
	Fleet.CAPITAL_SHIP_SLOT: preload("res://icons/capital_ship.png")
}
const PREVIEW_Z_INDEX := 4096

@export var id_label: Label
@export var name_edit: LineEdit
@export var ship_buttons: Container
@export var active_label: Label
@export var active_color := Color.WHITE
# These require @tool annotation to update properly
@export var active := false:
	set = set_active
@export var show_ships := true:
	set = set_show_ships
@export var show_ship_names := true:
	set = set_show_ship_names
@export var button_size := Vector2(250.0, 250.0):
	set = set_button_size

var fleet: Fleet:
	set = set_fleet

static func create() -> FleetContainer:
	return preload("res://ships_screen/fleet_container.tscn").instantiate()

func _ready() -> void:
	update_ui()
	add_ships()

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
	add_ships()
	fleet_changed.emit(fleet)

func set_active(is_active: bool) -> void:
	self_modulate = active_color if is_active else Color.WHITE
	active = is_active
	update_ui()

func set_show_ships(ships_visible: bool) -> void:
	show_ships = ships_visible
	update_ui()

func set_show_ship_names(names_visible: bool) -> void:
	show_ship_names = names_visible
	update_ui()

func set_button_size(new_button_size: Vector2) -> void:
	button_size = new_button_size
	update_ui()

func clear_ships() -> void:
	for button: ShipButton in ship_buttons.get_children():
		button.queue_free()

func update_button_sizes() -> void:
	for button: ShipButton in ship_buttons.get_children():
		button.custom_minimum_size = button_size

func update_button_names() -> void:
	for button: ShipButton in ship_buttons.get_children():
		button.show_name = show_ship_names

func add_ships() -> void:
	if not is_node_ready():
		return
	clear_ships()
	if fleet == null:
		return
	for slot in range(fleet.size):
		_add_ship(fleet.get_ship(slot), slot)

func _disconnect_old_fleet(old_fleet: Fleet) -> void:
	old_fleet.renamed.disconnect(update_ui)
	old_fleet.resized.disconnect(add_ships)
	old_fleet.ship_changed.disconnect(_on_fleet_ship_changed)

func _connect_new_fleet(new_fleet: Fleet) -> void:
	new_fleet.renamed.connect(update_ui)
	new_fleet.resized.connect(add_ships)
	new_fleet.ship_changed.connect(_on_fleet_ship_changed)

func update_ui() -> void:
	if not is_node_ready():
		return
	if fleet == null:
		_clear_ui()
	else:
		_set_ui()
	ship_buttons.visible = show_ships
	active_label.visible = active
	update_button_names()
	update_button_sizes()

func _set_ui() -> void:
	id_label.text = "Fleet #%d" % fleet.id
	name_edit.text = fleet.name
	name_edit.editable = true

func _clear_ui() -> void:
	id_label.text = ""
	name_edit.text = ""
	name_edit.editable = false

func update_slot(new_ship: ShipData, slot: int) -> bool:
	return fleet.set_ship(slot, new_ship) and fleet.save_ships()

func _add_ship(ship: ShipData, slot: int) -> void:
	var button := ShipButton.create()
	button.ship = ship
	button.in_fleet = true
	button.mini_icon = MINI_ICONS.get(slot)
	button.show_name = show_ship_names
	button.custom_minimum_size = button_size
	ship_buttons.add_child(button)
	#
	button.ship_changed.connect(update_slot.bind(slot) )
	button.pressed.connect(button_pressed.emit.bind(slot) )

func _get_drag_data(_at_position: Vector2) -> Variant:
	if fleet == null:
		return null
	var preview: FleetContainer = duplicate(DUPLICATE_SCRIPTS)
	preview.z_index = PREVIEW_Z_INDEX
	preview.z_as_relative = false
	set_drag_preview(preview)
	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is FleetContainer and data != self

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	swap_fleets(data)

func swap_fleets(other_container: FleetContainer) -> bool:
	assert(other_container != null)
	#
	var other_fleet := other_container.fleet
	other_container.fleet = fleet
	fleet = other_fleet
	return fleet.swap_priority(other_container.fleet)

## NOTE: This permanently deletes the fleet from its database!
func delete_fleet() -> bool:
	var success := fleet == null or fleet.delete()
	fleet = null
	return success

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		pressed.emit(fleet)

func _on_delete_fleet_pressed() -> void:
	delete_fleet()

func _on_name_focus_exited() -> void:
	_on_name_text_submitted(name_edit.text)

func _on_name_text_submitted(new_text: String) -> bool:
	return fleet != null and fleet.set_name(new_text) and fleet.save_metadata()

func _on_fleet_swap_button_pressed() -> void:
	Globals.main.state = Main.State.FLEET

func _on_fleet_ship_changed(new_ship: ShipData, slot: int) -> void:
	get_button(slot).ship = new_ship
