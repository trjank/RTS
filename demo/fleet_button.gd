extends MarginContainer
@onready var button = %Button
@onready var delete_button = %Button2
var method:Callable
var delete_method:Callable
var button_name="Untitled ship"

func _ready():
	button.text = button_name
	button.pressed.connect(method)
	delete_button.pressed.connect(delete_method)

func rebind(new_method:Callable):
	button.pressed.disconnect(method)
	button.pressed.connect(new_method)
	method = new_method

func rebind_delete(new_method:Callable):
	delete_button.pressed.disconnect(delete_method)
	delete_button.pressed.connect(new_method)
	delete_method = new_method
