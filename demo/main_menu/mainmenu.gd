extends Control

@onready var play_button  = %PlayButton
@onready var settings_button = %SettingsButton
@onready var state_manager = $"../../StateManager"


func _ready():
	play_button.pressed.connect(play_button_pressed)
	settings_button.pressed.connect(settings_button_pressed)
	pass # Replace with function body.

func settings_button_pressed():
	state_manager.ui = state_manager.UI.SETTINGS

func play_button_pressed():
	state_manager.state = state_manager.State.BATTLE
	state_manager.ui = state_manager.UI.NAVBAR
