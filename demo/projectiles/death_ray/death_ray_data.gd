class_name DeathRayData extends ProjectileData

const MASK := globals.Layer.SHIPS

var thickness := 0.5
var max_range := 10.0
var inner_beam_color := Color.WHITE
var outer_beam_color := Color.GREEN
var inner_beam_size := 0.05
var volatility := 0.05
var glow := 3.0
var hit_damage_multiplier := 1.0
var hit_energy_drain_multiplier := 1.0
var max_hits := 10

func calculate_net_damage(hits := max_hits) -> float:
	return hits * damage if is_equal_approx(hit_damage_multiplier, 1.0) else damage * (1.0 - hit_damage_multiplier ** hits) / (1.0 - hit_damage_multiplier)

func create_projectile(from: Weapon, to: Target) -> void:
	assert(from != null)
	#
	var death_ray := DeathRay.create()
	death_ray.data = self
	from.get_ship().add_sibling(death_ray)
	death_ray.begin_death_timer()
	death_ray.raycast_and_hit(from.global_position, to.global_position, MASK)
