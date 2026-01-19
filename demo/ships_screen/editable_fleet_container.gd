class_name EditableFleetContainer extends FleetContainer

signal delete_requested(fleet: FleetID)

static func create() -> EditableFleetContainer:
	return preload("res://ships_screen/editable_fleet_container.tscn").instantiate()
