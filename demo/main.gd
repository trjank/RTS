extends Node2D

const ship_t := preload('res://battle/Ship.tscn')
const cursor := preload("res://icons/cursor_default.png")
@export var battle: Battle
@onready var state_manager = $state_manager

func _ready():
	#Input.set_custom_mouse_cursor(cursor)
	state_manager.change_state(state_manager.BACKGROUND)
	state_manager.change_new_ui_state(state_manager.MAIN_MENU)
	return
	#var manager := PartManager.new()
	##var part1 := manager.new_part()
	##var part2 := manager.new_part()
	##part1.set_name("TEST1")
	##part2.set_name("TEST2")
	##manager.save()
	#manager.load()
	#print(manager.get_part(0).get_name())
	#print(manager.count_parts())
	#
	#for n in range(10):
		#var ship := ship_t.instantiate()
		#battle.add_child(ship)
		#ship.position = Vector2(100, 100) * n
