class_name ProjectileData extends PartData

const MIN_LIFETIME_SEC := 0.1

var damage := 0.0
var energy_drain := 0.0
var shield_penetration := 0.0
var push_force := 0.0
var effective_range := 0.0
var lifetime_sec := MIN_LIFETIME_SEC:
	set = set_lifetime_sec
var mining_rate := StrategicResources.new()
var mining_rate_data: Dictionary:
	get = get_mining_rate_data, set = set_mining_rate_data
var can_mine := false

func get_speed() -> float:
	return 0.0

func get_mining_rate_data() -> Dictionary:
	return mining_rate.to_dict()

func set_mining_rate_data(new_mining_rate_data: Dictionary) -> void:
	mining_rate.load_dict(new_mining_rate_data)

func set_lifetime_sec(new_lifetime_sec: float) -> void:
	lifetime_sec = maxf(new_lifetime_sec, MIN_LIFETIME_SEC)

func create_projectile(_from: Weapon, _to: Target, _cache: Array[Node3D] ) -> void:
	pass # (override this function)

func hit(target: Target, from_player: Player = null, modifiers := WeaponModifiers.NONE, dt := 1.0) -> void:
	if target == null:
		return
	if can_mine and from_player != null:
		target.mine(from_player.resources, mining_rate, dt)
	target.hit(modifiers.calculate_damage(damage) * dt, from_player, shield_penetration)
	target.drain_energy(modifiers.calculate_energy_drain(energy_drain) * dt)
