extends Control

const KEYBIND_SAVE_PATH := "user://keybinds"
const KEYBIND_ROW_SCENE = preload("res://settings/KeybindRow.tscn")

@onready var keybind_list = %keybind_list 

var _binding := false
var _old_key: InputEvent
var _action_to_bind: StringName

func begin_rebind(action: StringName, old_key: InputEvent)->void:
	_action_to_bind = action
	_old_key = old_key
	_binding = true

func end_rebind()->void:
	_binding = false

func is_custom_action(action: StringName)->bool:
	return not action.begins_with("ui_")

func get_actions()->Array:
	return InputMap.get_actions().filter(is_custom_action)

func add_keybind_row(action: StringName)->void:
	var key := InputMap.action_get_events(action)[0]
	var row := KEYBIND_ROW_SCENE.instantiate()
	row.action = action
	row.key = key.as_text()
	row.on_press = begin_rebind.bind(action, key)
	keybind_list.add_child(row)

func update_keybind_row(action: StringName, new_key: InputEvent)->void:
	var row := keybind_list.get_node(NodePath(action))
	row.key = new_key.as_text()
	row.on_press = begin_rebind.bind(action, new_key)

func _ready()->void:
	for action in get_actions():
		add_keybind_row(action)

func _input(event: InputEvent)->void:
	if not _binding or not event is InputEventKey or not event.pressed: return
	# Rebind the old key to the new event key
	InputMap.action_erase_event(_action_to_bind, _old_key)
	InputMap.action_add_event(_action_to_bind, event)
	update_keybind_row(_action_to_bind, event)
	end_rebind()
