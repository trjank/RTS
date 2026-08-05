class_name ImportShipPopup extends ConfirmationDialog

signal requested_import(ship_string: String)

@export var text_edit: TextEdit

func _ready() -> void:
	get_ok_button().hide()
	get_cancel_button().hide()
	reset_size()

func _on_cancel_button_pressed() -> void:
	canceled.emit()
	hide()

func _on_ok_button_pressed() -> void:
	confirmed.emit()
	requested_import.emit(text_edit.text)
	hide()
