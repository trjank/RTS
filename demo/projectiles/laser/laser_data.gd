class_name LaserData extends ProjectileData

var max_chains := 0:
	set = set_max_chains
var multihit_modifiers := WeaponModifiers.new()
var multihit_modifiers_data: Dictionary:
	get = get_multihit_modifiers_data,
	set = set_multihit_modifiers_data
var thickness := 1.0
var glow := 1.0
var volatility := 0.0:
	set = set_volatility
var drift_speed := 0.0
var inner_color := Color.WHITE
var outer_color := Color.RED

func get_speed() -> float:
	return INF

func get_multihit_modifiers_data() -> Dictionary:
	return multihit_modifiers.to_dict()

func set_volatility(new_volatility: float) -> void:
	volatility = absf(new_volatility)

func set_multihit_modifiers_data(new_multihit_modifiers_data: Dictionary) -> void:
	multihit_modifiers.load_dict(new_multihit_modifiers_data)

func set_max_chains(new_max_chains: int) -> void:
	max_chains = maxi(new_max_chains, 0)

func create_projectile(from: Weapon, to: Target, _cache: Array[Node3D] ) -> void:
	assert(from != null)
	#
	var laser := Laser.create()
	from.get_ship().add_sibling(laser)
	laser.data = self
	laser.modifiers = from.modifiers
	laser.player_owner = from.get_player_owner()
	laser.begin_death_timer()
	laser.multihit(from.get_global_barrel_position(), to)
