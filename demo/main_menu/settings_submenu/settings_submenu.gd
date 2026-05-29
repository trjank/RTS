extends VBoxContainer

signal back_button_pressed

@export var keybinds: VBoxContainer
@export var reset_button: Button
@export var volume_value: Label
@export var music_volume_value: Label

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _ready() -> void:
	for action in KeybindRow.get_custom_actions():
		keybinds.add_child(KeybindRow.create(action) )
	keybinds.move_child(reset_button, keybinds.get_child_count() - 1)

func _on_volume_slider_value_changed(value: float) -> void:
	globals.volume = value
	volume_value.text = "%.0f" % value

func _on_music_volume_slider_value_changed(value: float) -> void:
	globals.music_volume = value
	music_volume_value.text = "%.0f" % value
