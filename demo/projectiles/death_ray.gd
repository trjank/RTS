class_name DeathRay extends Sprite3D

var data: DeathRayData:
	set = set_data

static func _sort_by_axis(a, b, sort_axis: Vector3) -> bool:
	return a.position.cross(sort_axis) < b.position.cross(sort_axis)

static func create() -> DeathRay:
	return preload("res://projectiles/death_ray.tscn").instantiate()

func set_data(new_data: DeathRayData) -> void:
	if new_data == null:
		push_warning("Death Ray has null data and will be removed")
		return queue_free()
	data = new_data
	modulate = data.beam_color * data.beam_glow
	region_rect.size.y = data.beam_width

func begin_death_timer() -> void:
	create_tween().tween_property(self, "modulate:a", 0.0, data.lifetime_sec)
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func raycast(from: Vector3, to: Vector3, mask: int) -> Array:
	var shape := BoxShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	shape.size = Vector3(data.beam_width, data.beam_range, from.distance_to(to) )
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = mask
	return get_world_3d().direct_space_state.intersect_shape(query, data.max_hits)

## Returns number of objects hit (may be useful for visual effects)
func raycast_and_hit(from: Vector3, to: Vector3, mask: int, kill_credit: Player = null) -> int:
	position = from
	look_at(to)
	var colliders := raycast(from, to, mask)
	colliders.sort_custom(_sort_by_axis)
	var damage := data.damage
	var energy_drain := data.energy_drain
	for unit in colliders:
		unit.hit(damage, kill_credit)
		unit.drain_energy(energy_drain)
		damage *= data.hit_damage_multiplier
		energy_drain *= data.hit_energy_drain_multiplier
	region_rect.size.y = from.distance_to(to)
	return colliders.size()
