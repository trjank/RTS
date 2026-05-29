class_name KeybindRow extends HBoxContainer

@export var label: Label
@export var keybinds: Array[Button]

const NO_REBIND_EVENT := -1
const UNBOUND_KEYBIND_TEXT := "--"

static var match_in_parenthesis := RegEx.create_from_string("\\([^\\)]*\\)")

var _action: StringName
var _events: Array[InputEvent]
var _rebind_event := NO_REBIND_EVENT

static func create(action: StringName) -> KeybindRow:
	var row := preload("res://main_menu/settings_submenu/keybind_row.tscn").instantiate() as KeybindRow
	row._action = action
	return row

static func is_custom_action(input_action: StringName) -> bool:
	return not input_action.begins_with("ui_")

static func get_custom_actions() -> Array:
	return InputMap.get_actions().filter(is_custom_action)

static func event_to_string(event: InputEvent) -> String:
	return match_in_parenthesis.sub(event.as_text(), "", true).replace("Left Mouse Button", "LMB").replace("Right Mouse Button", "RMB")

func _ready() -> void:
	sync_to_input_map()
	for i in keybinds.size():
		keybinds[i].pressed.connect(_begin_rebind.bind(i) )
	label.text = _action

func sync_to_input_map() -> void:
	assert(InputMap.has_action(_action) )
	#
	_events = InputMap.action_get_events(_action)
	_events.resize(keybinds.size() )
	for i in keybinds.size():
		keybinds[i].text = event_to_string(_events[i] ) if _events[i] != null else UNBOUND_KEYBIND_TEXT
	_rebind_event = NO_REBIND_EVENT

func _begin_rebind(i: int) -> void:
	if _rebind_event != NO_REBIND_EVENT:
		return
	keybinds[i].text = UNBOUND_KEYBIND_TEXT
	_rebind_event = i

func _input(event: InputEvent) -> void:
	if _rebind_event == NO_REBIND_EVENT or event is InputEventMouseMotion:
		return
	if _events[_rebind_event] != null:
		InputMap.action_erase_event(_action, _events[_rebind_event] )
	InputMap.action_add_event(_action, event)
	_events[_rebind_event] = event
	keybinds[_rebind_event].text = event_to_string(event)
	_rebind_event = NO_REBIND_EVENT
