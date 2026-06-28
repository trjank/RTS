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
	#create_tween().tween_property()
	get_tree().create_timer(data.lifetime_sec).timeout.connect(queue_free)

func _can_chain(from: Ship, to: Ship) -> bool:
	return to.is_friend(from) and from.global_position.distance_to(to.global_position) <= data.chain_range

func _create_laser(i: int, from: Vector3, to: Vector3) -> void:
	multimesh.set_instance_transform(i, transform)

func chain(from: Ship, to: Ship) -> int:
	var ships := to.filter_nearest(_can_chain)
	var chains := mini(ships.size(), data.max_chains)
	var damage := data.damage
	var energy_drain := data.energy_drain
	multimesh.instance_count = 1 + chains
	multimesh.set_instance_transform(0, Transform3D(Basis()))
	#from.hit(damage, from.player_owner, data.shield_penetration)
	#from.drain_energy(energy_drain)
	##
	#damage *= data.chain_damage_multiplier
	#energy_drain *= data.chain_energy_drain_multiplier
	##
	#for i in chains:
		#ships[i].hit(damage, from.player_owner, data.shield_penetration)
		#ships[i].drain_energy(energy_drain)
		#chain_laser(to, ship, depth_left - 1, multiplier, visited)
	return chains
