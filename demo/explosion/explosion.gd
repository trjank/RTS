@tool
class_name Explosion extends MeshInstance3D

@export_tool_button("explode") var explode_button = explode
@export_tool_button("implode") var implode_button = implode

static func create() -> Explosion:
	return preload("res://explosion/explosion.tscn").instantiate()

func randomize_pattern() -> void:
	set_instance_shader_parameter("random_offset", Vector2(randf(), randf() ) )

func explode(duration := 0.4) -> void:
	randomize_pattern()
	create_tween().tween_property(self, "instance_shader_parameters/height_variation", 1.0, duration).from(0.0)
	#create_tween().tween_property(self, "instance_shader_parameters/alpha_threshold", 1.0, 3.0 * duration).from(0.0)

func implode(duration := 0.4) -> void:
	create_tween().tween_property(self, "instance_shader_parameters/height_variation", 0.0, duration).from(1.0)
	#create_tween().tween_property(self, "instance_shader_parameters/alpha_threshold", 0.0, 3.0 * duration).from(1.0)

func explode_implode() -> void:
	pass
