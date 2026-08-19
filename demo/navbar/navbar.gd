extends PanelContainer

@onready var chat = null

func chat_button_pressed():
	chat.visible = not chat.visible

func _on_battle_button_pressed() -> void:
	Globals.main.state = Main.State.BATTLE

func _on_design_button_pressed() -> void:
	Globals.main.state = Main.State.DESIGN

func _on_menu_button_pressed() -> void:
	Globals.main.state = Main.State.MAIN_MENU

func _on_ships_button_pressed():
	Globals.main.state = Main.State.FLEET
