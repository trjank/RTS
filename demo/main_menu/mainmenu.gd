extends CanvasLayer

@onready var play_button  = %PlayButton
@onready var settings_button = %SettingsButton
@onready var state_manager = $"../StateManager"
@onready var design_button = %DesignButton

func _ready():
	play_button.pressed.connect(go_to_battle)
	settings_button.pressed.connect(go_to_settings)
	design_button.pressed.connect(go_to_design)
	pass # Replace with function body.

func go_to_settings():
	state_manager.set_state(state_manager.State.SETTINGS)

func go_to_battle():
	state_manager.set_state(state_manager.State.BATTLE)

func go_to_design():
	state_manager.set_state(state_manager.State.DESIGN)
