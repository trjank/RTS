extends PanelContainer

@onready var chat_button = $MarginContainer/GridContainer/ChatButton
@onready var battle_button = $MarginContainer/GridContainer/BattleButton
@onready var design_button = $MarginContainer/GridContainer/DesignButton
@onready var menu_button = $MarginContainer/GridContainer/MenuButton
@onready var chat = $"../Chat"
@onready var state_manager = $"../../StateManager"

func _ready():
	chat_button.pressed.connect(chat_button_pressed)
	battle_button.pressed.connect(battle_button_pressed)
	design_button.pressed.connect(design_button_pressed)
	menu_button.pressed.connect(menu_button_pressed)

func menu_button_pressed():
	state_manager.ui = state_manager.UI.MAIN_MENU
	state_manager.state = state_manager.State.NONE

func chat_button_pressed():
	chat.visible = not chat.visible

func battle_button_pressed():
	state_manager.state = state_manager.State.BATTLE
	state_manager.ui = state_manager.UI.NAVBAR

func design_button_pressed():
	state_manager.state = state_manager.State.DESIGN
	state_manager.ui = state_manager.UI.NAVBAR
