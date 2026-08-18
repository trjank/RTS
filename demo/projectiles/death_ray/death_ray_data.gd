class_name DeathRayData extends ProjectileData

const MIN_COHESION := 0.0
const MAX_COHESION := 1.0

var max_hits := 10
var multihit_modifiers := WeaponModifiers.new()
var multihit_modifier_data: Dictionary:
	get = get_multihit_modifier_data,
	set = set_multihit_modifier_data
var thickness := 0.5
var glow := 3.0
var start_color := Color.WHITE
var end_color := Color.GREEN
var cohesion := MAX_COHESION:
	set = set_cohesion
var drift_speed := 1.0

func get_speed() -> float:
	return INF

func get_multihit_modifier_data() -> Dictionary:
	return multihit_modifiers.to_dict()

func set_multihit_modifier_data(new_multihit_modifier_data: Dictionary) -> void:
	multihit_modifiers.load_dict(new_multihit_modifier_data)

func set_cohesion(new_cohesion: float) -> void:
	cohesion = clampf(new_cohesion, MIN_COHESION, MAX_COHESION)

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
