extends Node2D

#const ship_t := preload('res://battle/Ship.tscn')
const cursor := preload("res://icons/cursor_default.png")
@export var battle: Battle
@export var state_manager: Node

func _ready():
	state_manager.ui = state_manager.UI.MAIN_MENU
