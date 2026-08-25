class_name LoadedUnitLogic extends PanelContainer

signal pressed

@export var selected_color: Color
@export var id_label: Label
@export var name_edit: LineEdit
@export var unsaved_indicator: Label
@export var delete_button: Button

var selected := false:
	set = set_selected
var unit_logic: UnitLogic:
	set = set_unit_logic

static func create() -> LoadedUnitLogic:
	return preload("res://unit_logic_editor/loaded_unit_logic.tscn").instantiate()

func set_selected(new_selected: bool) -> void:
	selected = new_selected
	self_modulate = selected_color if selected else Color.WHITE

func set_unit_logic(new_unit_logic: UnitLogic) -> void:
	if unit_logic != null:
		_disconnect_signals(unit_logic)
	if new_unit_logic != null:
		_setup_ui(new_unit_logic)
	else:
		_clear_ui()
	unit_logic = new_unit_logic

func rename_unit_logic(new_name: String) -> bool:
	return unit_logic != null and unit_logic.set_name(new_name) and unit_logic.save()

func _disconnect_signals(old_unit_logic: UnitLogic) -> void:
	old_unit_logic.renamed.disconnect(on_unit_logic_rename)
	old_unit_logic.save_changed.disconnect(on_unit_logic_save_changed)

func _connect_signals(new_unit_logic: UnitLogic) -> void:
	new_unit_logic.renamed.connect(on_unit_logic_rename)
	new_unit_logic.save_changed.connect(on_unit_logic_save_changed)

func _clear_ui() -> void:
	id_label.text = "--"
	name_edit.text = "EMPTY"
	name_edit.editable = false
	delete_button.disabled = true

func _setup_ui(new_unit_logic: UnitLogic) -> void:
	id_label.text = "#%d" % new_unit_logic.id
	name_edit.text = new_unit_logic.name
	name_edit.editable = true
	delete_button.disabled = false
	_connect_signals(new_unit_logic)

func on_unit_logic_save_changed(is_saved: bool) -> void:
	unsaved_indicator.visible = not is_saved

func on_unit_logic_rename(new_name: String) -> void:
	name_edit.text = new_name

func on_editor_unit_logic_changed(new_unit_logic: UnitLogic) -> void:
	selected = new_unit_logic == unit_logic

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		pressed.emit()

func _on_name_edit_focus_exited() -> void:
	rename_unit_logic(name_edit.text)

func _on_line_edit_text_submitted(new_text: String) -> void:
	rename_unit_logic(new_text)

func _on_delete_button_pressed() -> void:
	unit_logic.delete()
