@tool
class_name LaserTest extends Laser

# NOTE: This is used to test different laser shaders in the editor

@export var uv_ratio := 1.0:
	set = set_uv_ratio

func _ready() -> void:
	multimesh.instance_count = 1
	multimesh.set_instance_transform(0, Transform3D.IDENTITY)

func set_uv_ratio(new_uv_ratio: float) -> void:
	uv_ratio = new_uv_ratio
	multimesh.set_instance_custom_data(0, Color(uv_ratio, 0.0, 0.0, 0.0) )
