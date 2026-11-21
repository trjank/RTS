class_name BulletData extends ProjectileData

const MIN_SOUND_VARIATION := 0.0
const MAX_SOUND_VARIATION := 0.25

var launch_velocity := 0.0
var linear_damp := 0.0
var sound_variation := 0.1:
	set = set_sound_variation
var trail := TrailData.new()
var trail_data: Dictionary:
	get = get_trail_data, set = set_trail_data
var trail_enabled := false
var death_explosion := ExplosionData.new()
var death_explosion_data: Dictionary:
	get = get_death_explosion_data, set = set_death_explosion_data

func get_speed() -> float:
	return launch_velocity

func get_trail_data() -> Dictionary:
	return trail.to_dict()

func set_trail_data(new_trail_data: Dictionary) -> void:
	trail.load_dict(new_trail_data)

func get_death_explosion_data() -> Dictionary:
	return death_explosion.to_dict()

func set_death_explosion_data(new_death_explosion_data: Dictionary) -> void:
	death_explosion.load_dict(new_death_explosion_data)

func set_sound_variation(new_sound_variation: float) -> void:
	sound_variation = clampf(new_sound_variation, MIN_SOUND_VARIATION, MAX_SOUND_VARIATION)

func create_projectile(from: Weapon, to: Target, _cache: Array[Node3D] ) -> void:
	assert(from != null)
	#
	var bullet := Bullet.create()
	var ship := from.get_ship()
	bullet.battle = ship.battle
	bullet.data = self
	bullet.add_collision_exception_with(ship)
	ship.add_sibling(bullet)
	bullet.global_position = from.get_global_barrel_position()
	bullet.global_rotation = from.global_rotation
	bullet.launch(from.get_ship().linear_velocity)
	bullet.set_target(to)
	bullet.begin_death_timer()
