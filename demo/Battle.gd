extends Button

@export var design: Node2D
@export var battle: Battle

func _on_pressed():
	battle.show_overlay()
	battle.show()
	design.hide_overlay()
	design.hide()
