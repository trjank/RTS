extends PanelContainer

signal back_button_pressed

@export var saves_container: VBoxContainer
@export var team_settings: TeamSettings

func _ready() -> void:
	for i in range(Globals.NUM_SINGLEPLAYER_SAVES):
		saves_container.add_child(SingleplayerSaveFile.create() )
	Globals.main_ready.connect(_on_globals_main_ready)

func _on_globals_main_ready() -> void:
	team_settings.battle = Globals.main.nodes[Main.State.SINGLEPLAYER]

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _on_battle_settings_request_create_game() -> void:
	Globals.main.state = Main.State.SINGLEPLAYER
	Globals.main.nodes[Main.State.SINGLEPLAYER].start()
