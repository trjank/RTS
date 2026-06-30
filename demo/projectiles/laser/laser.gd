class_name Laser extends MultiMeshInstance3D

var data: LaserData:
	set = set_data

static func create() -> Laser:
	return preload("res://projectiles/laser/laser.tscn").instantiate()

func set_data(new_data: LaserData) -> void:
	if new_data == null:
		return queue_free()
	data = new_data

func begin_death_timer() -> void:
	#create_tween().tween_property(self, "alpha")
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func _can_chain(from: Ship, to: Ship) -> bool:
	return to.is_friend(from) and from.global_position.distance_to(to.global_position) <= data.chain_range

func _create_laser(i: int, from: Vector3, to: Vector3) -> void:
	assert(i < multimesh.instance_count)
	#
	var mesh_basis := Basis.looking_at(to - from, Vector3.UP)
	mesh_basis.z *= from.distance_to(to)
	var mesh_transform := Transform3D(mesh_basis, from)
	multimesh.set_instance_transform(i, mesh_transform)

func _create_laser_and_hit(i: int, from: Vector3, to: Ship, kill_credit: Player, damage: float, energy_drain: float) -> void:
	_create_laser(i, from, to.global_position)
	to.hit(damage, kill_credit, data.shield_penetration)
	to.drain_energy(energy_drain)

## Returns number of objects hit (can be used for visual effects)
func chain_to_target(from: Weapon, to: Target) -> int:
	if to is RadarSignature:
		return chain_to_ship(from, to.as_unit() )
	multimesh.instance_count = 1
	#_create_laser_and_hit(0, from.global_position, to, from.get_ship().player_owner, data.damage, data.energy_drain)
	return 1

## Returns number of objects hit (can be used for visual effects)
func chain_to_ship(from: Weapon, to: Ship) -> int:
	var ships := to.filter_nearest(_can_chain)
	var num_chains := mini(ships.size(), data.max_chains)
	var damage := data.damage
	var energy_drain := data.energy_drain
	#
	multimesh.instance_count = 1 + num_chains
	_create_laser_and_hit(0, from.global_position, to, from.get_ship().player_owner, damage, energy_drain)
	damage *= data.chain_damage_multiplier
	energy_drain *= data.chain_energy_drain_multiplier
	#
	for i in num_chains:
		_create_laser_and_hit(i, to.global_position, ships[i], from.get_ship().player_owner, damage, energy_drain)
	return num_chains
