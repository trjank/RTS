class_name ExplodeTest

const DURATION := 1.0

static func explode(node: Node3D) -> void:
	var explosion := preload("res://explosions/test.tscn").instantiate() as MeshInstance3D
	explosion.ready.connect(func ():
		explosion.create_tween().tween_property(explosion.get_child(0), "instance_shader_parameters/distortion_strength", 0.0, DURATION).from(1.0)
	)
	node.add_sibling(explosion)
	explosion.position = node.position
	explosion.create_tween().tween_property(explosion, "instance_shader_parameters/height_variation", 1.0, DURATION).from(0.0)
	explosion.create_tween().tween_property(explosion, "instance_shader_parameters/alpha_threshold", 1.0, DURATION).from(0.0)
	explosion.create_tween().tween_property(explosion, "instance_shader_parameters/emission_threshold", 1.0, 0.5 * DURATION).from(0.0)
	explosion.create_tween().tween_property(explosion, "scale", Vector3(10.0, 10.0, 10.0), DURATION).from(Vector3.ZERO)
	explosion.get_tree().create_timer(DURATION).timeout.connect(explosion.queue_free)

static func disintegrate() -> void:
	pass
