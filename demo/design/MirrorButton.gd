extends TextureButton

signal mirror_mode_changed

@export var mirror_axis: Line2D

var mirror_mode := false
var mirror_enabled_image  := preload("res://icons/mirror_mode_enabled.png")
var mirror_disabled_image := preload("res://icons/mirror_mode_disabled.png")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("mirror mode"):
		_on_button_down()

func _on_button_down():
	mirror_mode         = not mirror_mode
	mirror_axis.visible = mirror_mode
	texture_normal      = mirror_enabled_image if mirror_mode else mirror_disabled_image
	mirror_mode_changed.emit()
