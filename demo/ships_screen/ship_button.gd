@tool
class_name ShipButton extends Button

signal ship_changed(new_ship: ShipData)

const PREVIEW_Z_INDEX := 4096

@export var ship_id: Label
@export var unsaved_indicator: Label
@export var name_edit: LineEdit
@export var custom_icon: TextureRect
@export var panel_container: PanelContainer
# These require @tool annotation to update properly
@export var mini_icon: Texture:
	set = set_mini_icon
@export var show_name := false:
	set = set_show_name
@export var saved := true:
	set = set_saved
@export var in_fleet := false

var ship: ShipData:
	set = set_ship

static func create() -> ShipButton:
	return preload("res://ships_screen/ship_button.tscn").instantiate()

func _ready() -> void:
	update_ui()

func set_show_name(name_visible: bool) -> void:
	show_name = name_visible
	update_ui()

func set_saved(is_saved: bool) -> void:
	saved = is_saved
	update_ui()

func set_mini_icon(new_mini_icon: Texture) -> void:
	mini_icon = new_mini_icon
	update_ui()

func set_ship(new_ship: ShipData) -> void:
	if ship == new_ship:
		return
	if ship != null:
		_disconnect_signals(ship)
	if new_ship != null:
		_connect_signals(new_ship)
	ship = new_ship
	update_ui()
	ship_changed.emit(ship)

func _connect_signals(new_ship: ShipData) -> void:
	new_ship.generated_thumbnail.connect(update_ui)
	new_ship.renamed.connect(update_ui)

func _disconnect_signals(old_ship: ShipData) -> void:
	old_ship.generated_thumbnail.disconnect(update_ui)
	old_ship.renamed.disconnect(update_ui)

func update_ui() -> void:
	if not is_node_ready():
		return
	if ship == null:
		_clear_ui()
	else:
		_set_ui()
	panel_container.visible = show_name
	custom_icon.texture = mini_icon

func _set_ui() -> void:
	icon = ship.get_thumbnail_texture()
	ship_id.text = "#%d" % ship.id
	name_edit.text = ship.name
	name_edit.editable = true
	unsaved_indicator.visible = not saved

func _clear_ui() -> void:
	icon = null
	ship_id.text = ""
	name_edit.text = "Empty"
	name_edit.editable = false
	unsaved_indicator.visible = false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ShipButton and data != self and (in_fleet or not data.in_fleet)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if in_fleet == data.in_fleet:
		return swap_ships(data)
	ship = data.ship

func _get_drag_data(_at_position: Vector2) -> ShipButton:
	if ship == null:
		return
	var preview: ShipButton = duplicate(DuplicateFlags.DUPLICATE_SCRIPTS)
	var wrapper := _wrap_and_offset(preview, -0.5 * size)
	preview.ship = ship
	wrapper.z_index = PREVIEW_Z_INDEX
	wrapper.z_as_relative = false
	set_drag_preview(wrapper)
	return self

func _wrap_and_offset(button: ShipButton, offset: Vector2) -> Control:
	var wrapper := Control.new()
	wrapper.add_child(button)
	button.position = offset
	return wrapper

func swap_ships(other_button: ShipButton) -> bool:
	assert(other_button != null)
	#
	var other_ship := other_button.ship
	other_button.ship = ship
	ship = other_ship
	return in_fleet or other_button.in_fleet or ship.swap_priority(other_button.ship)

## NOTE: This can permanently delete the ship from its database!
func delete_ship() -> bool:
	var success := ship == null or ship.delete()
	ship = null
	return success

func _on_name_focus_exited() -> void:
	_on_name_text_submitted(name_edit.text)

func _on_name_text_submitted(new_text: String) -> bool:
	return ship != null and ship.set_name(new_text) and ship.save()
