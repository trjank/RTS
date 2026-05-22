class_name DeathRayData extends ProjectileData

var beam_width := 1.0
var beam_range := 10.0
var beam_color := Color.RED
var beam_glow := 1.0
var hit_damage_multiplier := 1.0
var hit_energy_drain_multiplier := 1.0
var max_hits := 10

func get_mask() -> int:
	return 0

func calculate_net_damage(hits := max_hits) -> float:
	return hits * damage if is_equal_approx(hit_damage_multiplier, 1.0) else damage * (1.0 - hit_damage_multiplier ** hits) / (1.0 - hit_damage_multiplier)

func create_projectile(from: Weapon, to: Target) -> void:
	assert(from != null)
	#
	var ray := DeathRay.create()
	ray.data = self
	from.get_ship().add_sibling(ray)
	ray.raycast_and_hit(from.global_position, to.position, get_mask() )
