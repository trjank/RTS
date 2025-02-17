extends Node2D

const ship_t := preload('res://core/Ship.tscn')

@export var container: Node2D

func _ready():
	for n in range(10):
		var ship := ship_t.instantiate()
		container.add_child(ship)
		ship.position = Vector2(100, 100) * n
