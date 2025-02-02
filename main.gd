extends Node2D

const unit_t := preload('res://core/UnitCPP.tscn')

func _ready():
	for n in range(2):
		var unit := unit_t.instantiate()
		$Objects.add_child(unit)
		unit.position = Vector2(500, 100 * n)
