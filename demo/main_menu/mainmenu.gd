extends CanvasLayer

@onready var mock_battle: Battle = $MockBattle

func _on_play_button_pressed()->void:
	globals.main.state = Main.State.BATTLE

func _on_design_button_pressed()->void:
	globals.main.state = Main.State.DESIGN

func _on_settings_button_pressed()->void:
	globals.main.state = Main.State.SETTINGS

func _ready()->void:
	mock_battle.start()
