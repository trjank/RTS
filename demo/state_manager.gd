extends Node

@onready var design = preload("res://design/design.tscn").instantiate()
@onready var mainmenu = preload("res://main_menu/mainmenu.tscn").instantiate()
@onready var settings = preload("res://settings/settings_menu.tscn").instantiate()
@onready var navbar = preload("res://navbar/navbar.tscn").instantiate()
@onready var ui_node = $"../UI"

enum State {NONE, BACKGROUND, BATTLE, DESIGN}
enum UI {NO_UI, NAVBAR, MAIN_MENU, SETTINGS}

var state := State.NONE
var ui := UI.NO_UI

@onready var battle = $"../Battle"

func remove_current_state()->void:
	match state:
		State.BATTLE:
			battle.hide_overlay()
			battle.hide()
		State.DESIGN:
			$"..".remove_child(design)
	state = State.NONE

func change_new_state(new_state):
	match new_state:
		State.BACKGROUND:
			battle.hide_overlay()
			battle.show()
			state = State.BACKGROUND
		State.BATTLE:
			#this feels really scuffed
			remove_current_ui_state()
			battle.show_overlay()
			battle.show()
			state = State.BATTLE
		State.DESIGN:
			change_new_ui_state(UI.NAVBAR)
			$"..".add_child(design)
			state = State.DESIGN
		_:
			state = State.NONE

func change_state(new_state):
	remove_current_state()
	change_new_state(new_state)

func remove_current_ui_state()->void:
	match ui:
		UI.NAVBAR:
			ui_node.remove_child(navbar)
		UI.MAIN_MENU:
			ui_node.remove_child(mainmenu)
		UI.SETTINGS:
			ui_node.remove_child(settings)
	ui = UI.NO_UI

func change_new_ui_state(new_state: UI)->void:
	match new_state:
		UI.NAVBAR:
			print("adding nav")
			ui_node.add_child(navbar)
			ui = UI.NAVBAR
		UI.MAIN_MENU:
			print("adding mainmenu")
			ui_node.add_child(mainmenu)
			ui = UI.MAIN_MENU
		UI.SETTINGS:
			print("adding settings")
			ui_node.add_child(settings)
			ui = UI.SETTINGS

func change_ui_state(new_state: UI):
	if new_state != ui:
		remove_current_ui_state()
	change_new_ui_state(new_state)
