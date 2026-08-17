class_name DeathRayData extends ProjectileData

var max_hits := 10
var multihit_modifiers := WeaponModifiers.new()
var multihit_modifiers_data: Dictionary:
	get = get_multihit_modifiers_data,
	set = set_multihit_modifiers_data
var thickness := 0.5
var inner_beam_size := 0.05
var glow := 3.0
var inner_color := Color.WHITE
var outer_color := Color.GREEN
var volatility := 0.05

func get_speed() -> float:
	return INF

func get_multihit_modifiers_data() -> Dictionary:
	return multihit_modifiers.to_dict()

func set_multihit_modifiers_data(new_multihit_modifiers_data: Dictionary) -> void:
	multihit_modifiers.load_dict(new_multihit_modifiers_data)

func create_projectile(from: Weapon, to: Target, _cache: Array[Node3D] ) -> void:
	assert(from != null)
	#
	var death_ray := DeathRay.create()
	var excluded := from.get_ship().get_rid()
	death_ray.data = self
	death_ray.modifiers = from.modifiers
	death_ray.player_owner = from.get_player_owner()
	from.get_ship().add_sibling(death_ray)
	death_ray.begin_death_timer()
	death_ray.raycast_and_hit(from.get_global_barrel_position(), to.global_position, [excluded] )
