class_name Trail extends MeshInstance3D

var data := TrailData.DEFAULT:
	set = set_data

static func create() -> Trail:
	return preload("res://trails/trail.tscn").instantiate()

func get_direction() -> Vector3:
	return transform.basis.z

func get_global_direction() -> Vector3:
	return global_transform.basis.z

func set_data(new_data: TrailData) -> void:
	data = new_data if new_data != null else TrailData.DEFAULT

func move(from: Vector3, to: Vector3) -> void:
	look_at_from_position(from, to)
	scale.z = from.distance_to(to)

func pulse(duration_sec: float, max_roundness := 10.0) -> void:
	create_tween().tween_property(self, "instance_shader_parameters/roundness", 0.0, duration_sec).from(max_roundness)

func randomize_flicker() -> void:
	set_instance_shader_parameter("random_phase_offset", randf_range(0.0, TAU) )

func update_shader() -> void:
	set_instance_shader_parameter("flicker_strength", data.flicker_strength)
	set_instance_shader_parameter("roundness", data.roundness)
	set_instance_shader_parameter("inner_color", data.glow * data.inner_color)
	set_instance_shader_parameter("outer_color", data.glow * data.outer_color)
