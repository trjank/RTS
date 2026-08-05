class_name BulletData extends ProjectileData

const MIN_MISSILE_TORQUE = 0.1
const MIN_SOUND_VARIATION := 0.0
const MAX_SOUND_VARIATION := 0.25

var launch_velocity := 0.0
var linear_damp := 0.0
var sound_variation := 0.1:
	set = set_sound_variation
var trail_enabled := false
var trail_inner_color := Color.ORANGE
var trail_outer_color := Color.RED
var trail_glow := 2.0
var trail_roundness := 1.0
var trail_flicker_strength := 0.1
var trail_force := 1.0
var trail_width_ratio := 1.0

func is_missile() -> bool:
	return MIN_MISSILE_TORQUE <= torque

func set_sound_variation(new_sound_variation: float) -> void:
	sound_variation = clampf(new_sound_variation, MIN_SOUND_VARIATION, MAX_SOUND_VARIATION)

func create_projectile(from: Weapon, to: Target, _cache: Array[Node3D] ) -> void:
	assert(from != null)
	#
	var bullet := Bullet.create()
	var ship := from.get_ship()
	bullet.data = self
	bullet.add_collision_exception_with(ship)
	ship.add_sibling(bullet)
	bullet.global_transform = from.global_transform
	bullet.launch(from.get_ship().linear_velocity)
	bullet.set_target(to)
	bullet.begin_death_timer()
