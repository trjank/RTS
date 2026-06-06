class_name Laser extends Sprite3D

var data: LaserData:
	set = set_data

var _visited: Array[Ship] = []

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
	return to.is_friend(from) and not to in _visited

func count_chains() -> int:
	return _visited.size()

func chain_to() -> void:
	pass

func chain(to: Ship, damage := data.damage, energy_drain := data.energy_drain) -> void:
	pass
	#var ships := to.filter_nearest(_can_chain)
	#from.hit(damage * multiplier, from.player_owner, shield_penetration)
	#from.drain_energy(energy_drain)
	#damage *= data.chain_damage_multiplier
	#energy_drain *= data.chain_energy_drain_multiplier
	#create_laser(from, to.global_position, multiplier)
	#for ship in ships:
		#visited.append(ship)
		#chain_laser(to, ship, depth_left - 1, multiplier, visited)
