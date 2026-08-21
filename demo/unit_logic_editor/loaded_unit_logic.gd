class_name LoadedUnitLogic extends HBoxContainer

var unit_logic: UnitLogic

func create() -> LoadedUnitLogic:
	return preload("res://unit_logic_editor/loaded_unit_logic.tscn").instantiate()

func _on_line_edit_text_submitted(new_text: String) -> void:
	pass

func _on_delete_button_pressed() -> void:
	pass
