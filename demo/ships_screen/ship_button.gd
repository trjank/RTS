class_name ShipButton extends Button

signal ship_changed(new_ship: ShipData)

@export var in_fleet := false
@export var mini_icon: Texture:
	set = set_mini_icon
@export var ship_id: Label
@export var unsaved_indicator: Label
@export var name_edit: LineEdit
@export var custom_icon: TextureRect

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
		ship.ui_update.disconnect(update_ui)
	if new_ship != null:
		new_ship.ui_update.connect(update_ui)
	ship = new_ship
	update_ui()
	ship_changed.emit(ship)

func update_ui() -> void:
	if not is_node_ready():
		return
	if ship == null:
		_clear_ui()
	else:
		_create_ship_ui()
	custom_icon.texture = mini_icon

func _create_ship_ui() -> void:
	icon = ship.get_texture()
	ship_id.text = "#%d" % ship.get_id()
	name_edit.text = ship.name
	name_edit.editable = true
	unsaved_indicator.visible = not saved

func _clear_ui() -> void:
	icon = null
	ship_id.text = ""
	name_edit.editable = false
	name_edit.text = "Empty"
	unsaved_indicator.visible = false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ShipButton and (in_fleet or not data.in_fleet)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var new_ship = data.ship
	if can_swap(self, data):
		data.ship = ship
	ship = new_ship

func _get_drag_data(_at_position: Vector2) -> Variant:
	if ship == null:
		return
	var preview: ShipButton = duplicate(DuplicateFlags.DUPLICATE_SCRIPTS)
	# NOTE: By default, previews have their top left corner at mouse
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
