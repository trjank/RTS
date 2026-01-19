class_name ShipButton extends Button

@export var id: Label
@export var unsaved_indicator: Label
@export var name_edit: LineEdit

var ship: ShipDataID:
	set = set_ship

static func create() -> ShipButton:
	return preload("res://design/ship_button.tscn").instantiate() as ShipButton

func _ready() -> void:
	update_ui()

func set_ship(new_ship: ShipDataID) -> void:
	if ship != null:
		ship.ship_changed.disconnect(update_ui)
	if new_ship == null:
		name_edit.editable = false
		name_edit.text = ""
	else:
		name_edit.editable = true
		new_ship.ship_changed.connect(update_ui)
	ship = new_ship
	update_ui()

func update_ui() -> void:
	if ship == null or not is_node_ready():
		return
	icon = ship.ship_data.texture
	name_edit.text = ship.ship_data.name
	id.text = "#%d" % ship.get_id()

func _on_name_text_submitted(new_text: String) -> void:
	ship.ship_data.name = new_text
	ship.save()

func _on_name_focus_exited() -> void:
	return
	ship.ship_data.name = name_edit.text
	ship.save()
