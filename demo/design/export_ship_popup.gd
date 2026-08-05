class_name ExportShipPopup extends AcceptDialog

@export var label: RichTextLabel
@export var copy_button: Button

var ship_string := "":
	set = set_ship_string

func _ready() -> void:
	get_ok_button().hide()
	reset_size()

func set_ship_string(new_ship_string: String) -> void:
	ship_string = new_ship_string
	label.text = ship_string

func _on_visibility_changed() -> void:
	copy_button.text = "Copy"

func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(ship_string)
	copy_button.text = "Copied!"
