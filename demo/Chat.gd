extends Button

@export var chat: CanvasLayer

func _on_pressed():
	chat.visible = not chat.visible
