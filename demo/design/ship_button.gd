class_name ShipButton extends Button

@export var id: Label
@export var unsaved_indicator: Label
@export var name_edit: LineEdit
@export var custom_icon: TextureRect

var in_fleet := false
var mini_icon: Texture:
	set = set_mini_icon
var ship: ShipDataID:
	set = set_ship

static func can_swap(button: ShipButton, other_button: ShipButton) -> bool:
	return button.in_fleet == other_button.in_fleet

static func create() -> ShipButton:
	return preload("res://design/ship_button.tscn").instantiate()

func _ready() -> void:
	update_ui()

func set_ship(new_ship: ShipDataID) -> void:
	if ship != null:
		ship.ship_changed.disconnect(update_ui)
	if new_ship != null:
		new_ship.ship_changed.connect(update_ui)
	ship = new_ship
	update_ui()

func set_mini_icon(new_mini_icon: Texture) -> void:
	mini_icon = new_mini_icon
	update_ui()

func update_ui() -> void:
	if not is_node_ready():
		return
	if ship != null:
		_create_ship_ui()
	else:
		_clear_ui()
	custom_icon.texture = mini_icon

func _create_ship_ui() -> void:
	icon = ship.ship_data.texture
	id.text = "#%d" % ship.get_id()
	name_edit.text = ship.ship_data.name

func _clear_ui() -> void:
	icon = null
	id.text = ""
	name_edit.text = ""

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ShipButton and (in_fleet or not data.in_fleet)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var new_ship = data.ship
	if can_swap(self, data):
		data.ship = ship
	ship = new_ship

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := duplicate()
	var center_preview := Control.new()
	center_preview.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(center_preview)
	return self

func _on_name_text_submitted(new_text: String) -> void:
	ship.ship_data.name = new_text
	ship.save()

func _on_name_focus_exited() -> void:
	return
	ship.ship_data.name = name_edit.text
	ship.save()
