extends Node

enum State {DESIGN, MAIN_MENU, SETTINGS, BATTLE}

@onready var design := preload("res://design/design.tscn").instantiate()
@onready var mainmenu := preload("res://main_menu/mainmenu.tscn").instantiate()
@onready var settings := preload("res://settings/settings_menu.tscn").instantiate()
@onready var battle := preload("res://battle/battle.tscn").instantiate()
@onready var main = get_owner()


#state for when game starts
var DEFAULT_STATE := State.MAIN_MENU
var current_state := DEFAULT_STATE

@onready var states := {
	State.DESIGN: design,
	State.MAIN_MENU: mainmenu,
	State.SETTINGS: settings,
	State.BATTLE : battle
}




# IMPORTANT: Ensure this _ready occurs AFTER all of the other nodes
func _ready()->void:
	main.add_child.call_deferred(states[current_state])
	pass


func set_state(new_state: State)->void:
	var current_scene = states[current_state]
	var new_scene = states[new_state]

	var current_node = main.get_node(current_scene.get_path())
	print(current_scene) 
	print(current_node)
	main.remove_child(current_node)
	main.add_child(new_scene)
	current_state = new_state
