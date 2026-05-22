class_name LaserData extends ProjectileData

var beam_width := 1.0
var beam_color := Color.RED
var beam_glow := 1.0
var max_chains := 1:
	set = set_max_chains
var chain_damage_multiplier := 1.0
var chain_energy_drain_multiplier := 1.0

var _visited: Array[Ship] = []

func get_chain_damage() -> float:
	return damage * chain_damage_multiplier

func get_chain_energy_drain() -> float:
	return energy_drain * chain_energy_drain_multiplier

func set_max_chains(new_max_chains: int) -> void:
	max_chains = maxi(new_max_chains, 0)

func calculate_net_damage(num_chains := max_chains) -> float:
	return damage + get_chain_damage() * num_chains

func calculate_net_energy_drain(num_chains := max_chains) -> float:
	return energy_drain + get_chain_energy_drain() * num_chains

func _can_chain(to_ship: Ship, from_ship: Ship) -> bool:
	return to_ship.is_friend(from_ship) and not to_ship in _visited

func create_projectile(from: Weapon, to: Target) -> void:
	assert(from != null)
	#
	var laser := Laser.new()
	laser.begin_death_timer()
	from.get_ship().add_sibling(laser)
	if not to is RadarSignature or to.as_unit():
		return
	var chain_damage := get_chain_damage()
	var chain_drain := get_chain_energy_drain()
	#var chains := to.filter_nearest(_can_chain.bind(ship) )
	#for i in mini(max_chains, chains.size() ):
		#laser.chain_to(chains[i].position)
		#chains[i].hit(chain_damage)
		#chains[i].drain_energy(chain_drain)
