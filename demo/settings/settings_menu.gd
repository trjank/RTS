extends Control
@onready var backbutton = %back_button
@onready var stateManager = $"../../state_manager"

# Called when the node enters the scene tree for the first time.
func _ready():
	backbutton.pressed.connect(back_button_pressed)
	pass # Replace with function body.

func back_button_pressed():
	stateManager.change_ui_state(stateManager.MAIN_MENU)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
