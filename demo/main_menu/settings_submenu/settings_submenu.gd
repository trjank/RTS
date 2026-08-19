extends PanelContainer

signal back_button_pressed

@export var keybind_rows: VBoxContainer
@export var reset_button: Button
@export var volume_value: Label
@export var music_volume_value: Label
@export var volume_slider: HSlider
@export var music_volume_slider: HSlider

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _ready() -> void:
	for action in KeybindRow.get_custom_actions():
		keybind_rows.add_child(KeybindRow.create(action) )
	volume_slider.value = Globals.volume
	music_volume_slider.value = Globals.music_volume

func sync_keybind_rows() -> void:
	for keybind_row in keybind_rows.get_children():
		keybind_row.sync_to_input_map()

func _on_volume_slider_value_changed(value: float) -> void:
	Globals.volume = value
	volume_value.text = "%.0f" % value

func _on_music_volume_slider_value_changed(value: float) -> void:
	Globals.music_volume = value
	music_volume_value.text = "%.0f" % value

func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	sync_keybind_rows()
