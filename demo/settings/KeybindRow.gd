extends MarginContainer

var action: StringName = "": set = set_action
var key := "": set = set_key
var on_press := func()->void: push_error("No keybind connected!"): set = set_on_press

@onready var action_name_label: Label = %ActionName
@onready var key_name_button: Button = %KeyNameButton

func set_action(new_action: StringName)->void:
	# Change the name so get_node works
	name = new_action
	action = new_action
	if not is_node_ready(): return
	action_name_label.text = new_action

func set_key(new_key: String)->void:
	key = new_key
	if not is_node_ready(): return
	key_name_button.text = key

func set_on_press(new_on_press: Callable)->void:
	on_press = new_on_press
	if not is_node_ready(): return
	# Only one keybind is allowed per row
	key_name_button.pressed.disconnect(on_press)
	key_name_button.pressed.connect(new_on_press)

func _ready()->void:
	action_name_label.text = action
	key_name_button.text = key
	key_name_button.pressed.connect(on_press)
