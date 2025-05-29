extends Button

@export var design: Node2D
@export var battle: Battle

func _on_pressed():
	battle.hide_overlay()
	battle.hide()
	design.show_overlay()
	design.show()
