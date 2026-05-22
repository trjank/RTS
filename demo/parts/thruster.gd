class_name Thruster extends Part

@export var trail: Sprite3D

func _ready() -> void:
	#trail.position.y = 0.5 * size.y - 30.0
	trail.set_instance_shader_parameter("time_offset", randf_range(0.0, 10.0) )

func _process(_dt: float) -> void:
	if _ship == null:
		return
	trail.scale.y = _ship.get_speed() / _ship.get_max_speed()
