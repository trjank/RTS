extends Control
@onready var backbutton = %back_button
@onready var state_manager = $"../../StateManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	backbutton.pressed.connect(back_button_pressed)
	pass # Replace with function body.

func back_button_pressed():
	state_manager.ui = state_manager.UI.MAIN_MENU
