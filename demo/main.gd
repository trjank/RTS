extends Node2D

const ship_t := preload('res://core/Ship.tscn')

func _ready():
	for n in range(10):
		var ship := ship_t.instantiate()
		$Objects.add_child(ship)
		ship.position = Vector2(100, 100) * n
