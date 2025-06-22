extends PanelContainer

@onready var chat_button = $MarginContainer/GridContainer/ChatButton
@onready var battle_button = $MarginContainer/GridContainer/BattleButton
@onready var design_button = $MarginContainer/GridContainer/DesignButton
@onready var menu_button = $MarginContainer/GridContainer/MenuButton
@onready var chat = $"../Chat"
@onready var stateManager = $"../../state_manager"


func _ready():
	chat_button.pressed.connect(chat_button_pressed)
	battle_button.pressed.connect(battle_button_pressed)
	design_button.pressed.connect(design_button_pressed)
	menu_button.pressed.connect(menu_button_pressed)
	pass # Replace with function body.


		
func menu_button_pressed():
	stateManager.change_ui_state("MAIN_MENU")
	stateManager.change_state("BACKGROUND")

func chat_button_pressed():
	chat.visible = not chat.visible


func battle_button_pressed():
	stateManager.change_state("BATTLE")



func design_button_pressed():
	stateManager.change_state("DESIGN")
	print("design_button")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
