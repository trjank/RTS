class_name ShipButton extends Button

signal ship_changed(new_ship: ShipData)

@export var in_fleet := false
@export var mini_icon: Texture:
	set = set_mini_icon
@export var ship_id: Label
@export var unsaved_indicator: Label
@export var name_edit: LineEdit
@export var custom_icon: TextureRect
@export var panel_container: PanelContainer

var collapsed := false:
	set = set_collapsed
var saved := true:
	set = set_saved
var ship: ShipData:
	set = set_ship

static func can_swap(button: ShipButton, other_button: ShipButton) -> bool:
	return button.in_fleet == other_button.in_fleet

static func create() -> ShipButton:
	return preload("res://ships_screen/ship_button.tscn").instantiate()

func _ready() -> void:
	update_ui()

func is_collapsed() -> bool:
	return panel_container.visible

func set_collapsed(collapse: bool) -> void:
	collapsed = collapse
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
	custom_icon.texture = mini_icon
	panel_container.visible = not collapsed

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
	return data is ShipButton and (in_fleet or not data.in_fleet)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var new_ship = data.ship
	if can_swap(self, data):
		data.ship = ship
	ship = new_ship

func _get_drag_data(_at_position: Vector2) -> ShipButton:
	if ship == null:
		return
	var preview: ShipButton = duplicate(DuplicateFlags.DUPLICATE_SCRIPTS)
	# Need an extra control node to have the center be at the mouse position
	var center_preview := Control.new()
	center_preview.add_child(preview)
	preview.ship = ship
	preview.position = -size / 2
	set_drag_preview(center_preview)
	return self

func _on_name_focus_exited() -> void:
	_on_name_text_submitted(name_edit.text)

func _on_name_text_submitted(new_text: String) -> bool:
	return ship != null and ship.set_name(new_text) and ship.save()
