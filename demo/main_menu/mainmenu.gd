extends Control

@onready var play_button  = %PlayButton
@onready var settings_button = %SettingsButton
@onready var stateManager = $"../../state_manager"


func _ready():
	play_button.pressed.connect(play_button_pressed)
	settings_button.pressed.connect(settings_button_pressed)
	pass # Replace with function body.

func settings_button_pressed():
	stateManager.change_ui_state(stateManager.SETTINGS)

func play_button_pressed():
	stateManager.change_state(stateManager.BATTLE)
	#stateManager.change_ui_state(stateManager.NAVBAR)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
