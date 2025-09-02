extends MarginContainer

#name of the action
var keybind_action:String = "keybind name"

#name of the key pressed
var keybind_key = "string"


var keybind_fn:Callable

#name for use in keymap
var keymap_key = "none"
@onready var keybind_name_label = %keybind_name
@onready var keybind_button = %keybind

func _ready():
	keybind_name_label.text = keybind_action
	keybind_button.text = keybind_key
	keybind_button.pressed.connect(keybind_fn)

func update_keybind(new_keybind_key,new_fn):
	keybind_button.pressed.disconnect(keybind_fn)
	keybind_fn = new_fn
	keybind_key = new_keybind_key
	keybind_button.text = keybind_key
	keybind_button.pressed.connect(new_fn)
