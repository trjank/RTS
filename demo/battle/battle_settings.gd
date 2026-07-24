class_name BattleSettings extends VBoxContainer

signal request_create_game

func _on_create_game_button_pressed() -> void:
	request_create_game.emit()
