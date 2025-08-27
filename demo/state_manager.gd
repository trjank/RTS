extends Node

@onready var design = preload("res://design/design.tscn").instantiate()
@onready var mainmenu = preload("res://main_menu/mainmenu.tscn").instantiate()
@onready var settings = preload("res://settings/settings_menu.tscn").instantiate()
@onready var navbar = preload("res://navbar/navbar.tscn").instantiate()
@onready var ui = $"../UI"


# const BACKGROUND = "BACKGROUND"
# const NONE      = "NONE"
# const DESIGN    = "DESIGN"
# const BATTLE    = "BATTLE"
# const NO_UI     = "NO_UI"
# const NAVBAR    = "NAVBAR"
# const MAIN_MENU = "MAIN_MENU"
enum {NONE, NO_UI,BACKGROUND ,DESIGN, BATTLE, NAVBAR, MAIN_MENU, SETTINGS}
var state = NONE
var ui_state = NO_UI

@onready var battle = $"../Battle"
func _ready():
	print(ui)
	pass

#could maybe abstract a bit here, there seems to be 2 layers (game, and UI), instead of duplicating functions for each layer, the layer could just be a class. could also use a data strucutre for the states themselves..

func remove_current_state():
	match state:
		BATTLE:
			battle.hide_overlay()
			battle.hide()
		DESIGN:
			$"..".remove_child(design)
	state = NONE


func change_new_state(new_state):
	match new_state:
		BACKGROUND:
			battle.hide_overlay()
			battle.show()
			state = BACKGROUND
		BATTLE:
			#this feels really scuffed
			remove_current_ui_state()
			battle.show_overlay()
			battle.show()
			state = BATTLE
		DESIGN:
			change_new_ui_state(NAVBAR)
			$"..".add_child(design)
			state = DESIGN
		_:
			state = NONE

func change_state(new_state):
	remove_current_state()
	change_new_state(new_state)

func remove_current_ui_state():
	match ui_state:
		NAVBAR:
			ui.remove_child(navbar)
		MAIN_MENU:
			ui.remove_child(mainmenu)
		SETTINGS:
			ui.remove_child(settings)
	ui_state = NO_UI

func change_new_ui_state(new_state):
	match new_state:
		NAVBAR:
			print("adding nav")
			ui.add_child(navbar)
			ui_state = NAVBAR
		MAIN_MENU:
			print("adding mainmenu")
			ui.add_child(mainmenu)
			ui_state = MAIN_MENU
		SETTINGS:
			print("adding settings")
			ui.add_child(settings)
			ui_state = SETTINGS

func change_ui_state(new_state):
	if new_state!=ui_state:
		remove_current_ui_state()
	change_new_ui_state(new_state)


func _process(_delta):
	pass
