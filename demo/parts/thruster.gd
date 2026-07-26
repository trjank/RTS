class_name Thruster extends Part

@export var trail: MeshInstance3D

func _ready() -> void:
	trail.set_instance_shader_parameter("outer_color", data.trail_glow * data.trail_outer_color)
	trail.set_instance_shader_parameter("inner_color", data.trail_glow * data.trail_inner_color)
	trail.set_instance_shader_parameter("roundness", data.trail_roundness)
	trail.set_instance_shader_parameter("flicker_strength", data.trail_flicker_strength)
	trail.set_instance_shader_parameter("random_phase_offset", randf_range(0.0, TAU) )

func _process(_dt: float) -> void:
	trail.scale.x = data.trail_width_ratio * get_size_2d().x
	trail.scale.z = data.trail_force * _ship.get_speed() if _ship != null else 1.0
