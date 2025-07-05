extends MarginContainer
@onready var button = %Button
var method:Callable
var button_name="Untitled ship"
func _ready():
	button.text = button_name
	button.pressed.connect(method)
	pass
