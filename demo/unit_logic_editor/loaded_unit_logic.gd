class_name LoadedUnitLogic extends HBoxContainer

var selected := false:
	set = set_selected
var unit_logic: UnitLogic

static func create() -> LoadedUnitLogic:
	return preload("res://unit_logic_editor/loaded_unit_logic.tscn").instantiate()

func set_selected(new_selected: bool) -> void:
	selected = new_selected
	# TODO: CHANGE COLOR

func on_editor_unit_logic_changed(new_unit_logic: LoadedUnitLogic) -> void:
	selected = new_unit_logic == self

func _on_line_edit_text_submitted(new_text: String) -> void:
	pass

func _on_delete_button_pressed() -> void:
	pass
