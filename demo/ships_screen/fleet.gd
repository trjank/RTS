extends PanelContainer

signal delete_requested(fleet: FleetID)

const ICON := preload("res://icons/icon.svg")

@onready var container := %Ships

var fleet_id: FleetID

func mark_as_selected(is_selected: bool)->void:
	%Selected.visible = is_selected

func _ready():
	add_fleet(null)

func add_fleet(new_fleet_id: FleetID)->void:
	fleet_id = new_fleet_id
	for _n in range(10):
		var image := TextureButton.new()
		image.texture_normal = ICON
		container.add_child(image)

func _on_delete_fleet_pressed()->void:
	delete_requested.emit(fleet_id)

func _on_fleet_name_text_submitted(new_text: String)->void:
	fleet_id.fleet.name = new_text
	globals.ship_db.save_fleet_metadata(fleet_id)
