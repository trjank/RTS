extends Control

@onready var play_button  = %PlayButton
@onready var settings_button = %SettingsButton
@onready var stateManager = $"../../state_manager"


func _ready():
	play_button.pressed.connect(play_button_pressed)
	pass # Replace with function body.

func play_button_pressed():
	stateManager.change_state("BATTLE")
	stateManager.change_ui_state("NAVBAR")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
