extends PanelContainer

signal ship_change_requested(ship: ShipDataID)

const OPACITY_SELECTED := 1.0
const OPACITY_DESELECTED := 0.5

var ship: ShipDataID:
	set = set_ship

func _on_texture_button_pressed() -> void:
	ship_change_requested.emit(ship)

func show_save_status(is_saved: bool) -> void:
	%UnsavedAsterisk.visible = not is_saved

func show_ship_icon(ship_data: ShipData) -> void:
	%TextureButton.texture_normal = ship_data.get_image()

func show_selected(selected_ship: ShipDataID) -> void:
	modulate.a = OPACITY_SELECTED if selected_ship == ship else OPACITY_SELECTED

func set_ship(new_ship: ShipDataID) -> void:
	if new_ship == ship:
		return
	if ship != null:
		# Prevent past ships from messing up the UI
		ship.ship_changed.disconnect(show_ship_icon)
		ship.save_changed.disconnect(show_save_status)
	if new_ship != null:
		# Ensure updates to current ship automatically update the UI
		ship = new_ship
		show_ship_icon(ship.ship_data)
		show_save_status(ship.is_saved)
		ship.ship_changed.connect(show_ship_icon)
		ship.save_changed.connect(show_save_status)
	else:
		pass
