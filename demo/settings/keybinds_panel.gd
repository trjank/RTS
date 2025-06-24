extends Control


const KeybindRowScene = preload("res://settings/keybind_row.tscn")
@onready var keybind_list = %keybind_list 
#still need to save keybinds, and possibly add a defaults file to read from

const bindable_inputs = {
	#keymap_key:action
	"left":"Pan Left",
	"right":"Pan Right",
	"up":"Pan Up",
	"down":"Pan Down", 
	"in": "Zoom In",
	"out":"Zoom Out",
	"select":"Select",
	"move":"Move",
	"target":"Target",
	"stop":"Stop",
	"line formation":"Enable Line Formation",
	"v formation":"Enable V Formation",
	"smooth formation":"Enable Smooth Formation",
	"precise formation":"Enable Precise Formation",
	"toggle queue move":"Toggle queue mode",
	"rotate cw":"Rotate Clockwise",
	"rotate ccw":"Rotate Counter-Clockwise",
	"delete":"Delete",
	"mirror mode":"Toggle mirror mode"
}

var binding = false
var key_to_bind = ""
var old_key:InputEvent


func new_keybind_row(keymap_key,keybind_action, keybind_key, keybind_fn):
	var new_row = KeybindRowScene.instantiate()
	new_row.keymap_key = keymap_key
	new_row.keybind_action = keybind_action
	new_row.keybind_key = keybind_key
	new_row.name = keymap_key
	new_row.keybind_fn = keybind_fn
	#new_row.update_text()
	#print(new_row.keybind_button) #.pressed.connect(rebind)
	return new_row

func update_keybind_row(keymap_key, event):
	var row = keybind_list.get_node(keymap_key)
	var new_fn = start_rebind.bind(keymap_key,event)
	var new_keybind_key = event.as_text()
	row.update_keybind(new_keybind_key,new_fn)


func start_rebind(keymap_key, oldkey):
	print("rebinding "+keymap_key+" ("+oldkey.as_text()+")")
	key_to_bind = keymap_key
	old_key = oldkey
	binding = true

func unbind_key(key_name, key):
	InputMap.action_erase_event(key_name, key)


func bind_key(key_name, key):
	InputMap.action_add_event(key_name, key)
	print("rebound with "+key.as_text())

func end_rebind():
	print("rebind done")
	binding = false
	

#not sure about using a global variable to track what key is being bound..
func _input(event):
	#only listen if binding, is a keyboard event, and if key was pressed down
	if not binding or not event is InputEventKey or not event.pressed: return
	unbind_key(key_to_bind, old_key)
	bind_key(key_to_bind, event)
	update_keybind_row(key_to_bind, event)
	end_rebind()

# Called when the node enters the scene tree for the first time.
func _ready():
	for keymap_key in bindable_inputs:
		print(keymap_key)
		var keybind_action = bindable_inputs[keymap_key]
		var keybind_key = InputMap.action_get_events(keymap_key)[0]
		print(keybind_key)
		var keybind_fn = start_rebind.bind(keymap_key,keybind_key)
		keybind_list.add_child(new_keybind_row(keymap_key, keybind_action, keybind_key.as_text(), keybind_fn))
		#print(get_node(keymap_key).keybind_button)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
