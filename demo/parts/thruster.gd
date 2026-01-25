@tool
class_name Thruster extends Part

@export var trail: Sprite2D

func _ready() -> void:
	trail.position.y = 0.5 * size.y

func _process(_dt: float) -> void:
	if _ship == null:
		return
	trail.scale.y = _ship.get_speed() / _ship.get_max_speed()
