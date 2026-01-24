extends Label

func _on_unit_formation_formation_changed(new_formation: UnitFormation.Formation) -> void:
	var formation_name = UnitFormation.Formation.find_key(new_formation)
	text = "Formation: " + formation_name if formation_name != null else "Formation: CUSTOM"

func _on_unit_formation_action_changed(new_action: UnitFormation.Action) -> void:
	visible = new_action == UnitFormation.Action.MOVE or new_action == UnitFormation.Action.QUEUE_MOVE
