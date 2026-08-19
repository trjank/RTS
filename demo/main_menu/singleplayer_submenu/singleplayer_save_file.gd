class_name SingleplayerSaveFile extends HBoxContainer

signal request_load
signal request_save

func _on_load_save_pressed() -> void:
	request_load.emit()
	Globals.main.state = Main.State.SINGLEPLAYER

func _on_delete_save_pressed() -> void:
	request_save.emit()
