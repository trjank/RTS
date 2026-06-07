class_name Thruster extends Part

@export var trail: MeshInstance3D

func _ready() -> void:
	trail.set_instance_shader_parameter("outer_color", data.trail_glow * data.trail_outer_color)
	trail.set_instance_shader_parameter("inner_color", data.trail_glow * data.trail_inner_color)
	trail.set_instance_shader_parameter("roundness", data.trail_roundness)
	trail.set_instance_shader_parameter("flicker_strength", data.trail_flicker_strength)
	trail.set_instance_shader_parameter("random_phase_offset", randf_range(0.0, TAU) )

func _process(_dt: float) -> void:
	if _ship == null:
		return
	trail.scale = Vector3(data.trail_width, data.trail_width, data.trail_force * _ship.get_speed() )
