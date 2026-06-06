class_name DeathRay extends MeshInstance3D

@export var sound_effect: AudioStreamPlayer3D

var data: DeathRayData:
	set = set_data

static func create() -> DeathRay:
	return preload("res://projectiles/death_ray/death_ray.tscn").instantiate()

static func _sort_by_axis(a: Node3D, b: Node3D, sort_axis: Vector3) -> bool:
	return a.global_position.cross(sort_axis) < b.global_position.cross(sort_axis)

static func _collider_to_node(collider: Dictionary) -> Node3D:
	return collider["collider"]

func get_forward_direction() -> Vector3:
	return -transform.basis.z

func get_global_forward_direction() -> Vector3:
	return -global_transform.basis.z

func set_data(new_data: DeathRayData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data
	mesh.size = Vector2(data.thickness, 0.0)
	set_instance_shader_parameter("outer_beam_color", data.outer_beam_color * data.glow)
	set_instance_shader_parameter("inner_beam_color", data.inner_beam_color * data.glow)
	set_instance_shader_parameter("inner_beam_size", data.inner_beam_size)
	set_instance_shader_parameter("volatility", data.volatility)

func begin_death_timer() -> void:
	create_tween().tween_property(self, "instance_shader_parameters/alpha", 0.0, data.lifetime_sec)
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func raycast(length: float, mask: int) -> Array:
	var shape := BoxShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	shape.size = Vector3(data.thickness, data.thickness, length)
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = mask
	return get_world_3d().direct_space_state.intersect_shape(query, data.max_hits).map(_collider_to_node)

func sorted_raycast(length: float, mask: int) -> Array:
	var colliders := raycast(length, mask)
	var sort_axis := get_global_forward_direction()
	colliders.sort_custom(_sort_by_axis.bind(sort_axis) )
	return colliders

func play_sound_effect() -> void:
	sound_effect.pitch_scale = sound_effect.stream.get_length() / data.lifetime_sec
	sound_effect.play()

## Returns number of objects hit (can be used for visual effects)
func raycast_and_hit(from: Vector3, to: Vector3, mask: int, kill_credit: Player = null) -> int:
	global_position = 0.5 * (from + to)
	look_at(to)
	var length := from.distance_to(to)
	var colliders := sorted_raycast(length, mask)
	var damage := data.damage
	var energy_drain := data.energy_drain
	#
	for unit in colliders:
		unit.hit(damage, kill_credit)
		unit.drain_energy(energy_drain)
		damage *= data.hit_damage_multiplier
		energy_drain *= data.hit_energy_drain_multiplier
	mesh.size.y = length
	play_sound_effect()
	return colliders.size()
