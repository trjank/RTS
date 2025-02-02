extends Node2D

const unit_t := preload('res://core/Unit.tscn')

func _ready():
	for n in range(10):
		var unit := unit_t.instantiate()
		$Objects.add_child(unit)
		unit.position = Vector2(100, 100) * n
