class_name EditableFleetContainer extends FleetContainer

const SELECTED_COLOR := Color(1.0, 0.75, 0.75, 1.0)

signal delete_requested(fleet: Fleet)
signal selected(fleet: Fleet)

static func create() -> EditableFleetContainer:
	return preload("res://ships_screen/editable_fleet_container.tscn").instantiate()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		selected.emit(fleet)

func _on_fleet_changed(selected_fleet: Fleet) -> void:
	var is_selected = fleet == selected_fleet
	modulate = SELECTED_COLOR if is_selected else Color.WHITE

func _on_delete_fleet_pressed() -> void:
	delete_requested.emit(fleet)
