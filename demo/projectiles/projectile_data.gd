class_name ProjectileData extends PartData

const MIN_LIFETIME_SEC := 0.1

var damage := 0.0
var energy_drain := 0.0
var shield_penetration := 0.0
var lifetime_sec := MIN_LIFETIME_SEC:
	set = set_lifetime_sec
var can_mine := false
var mining_rate := StrategicResources.new()
var mining_rate_data: Dictionary:
	get = get_mining_rate_data,
	set = set_mining_rate_data

func get_mining_rate_data() -> Dictionary:
	return mining_rate.to_dict()

func set_mining_rate_data(new_mining_rate_data: Dictionary) -> void:
	mining_rate.load_dict(new_mining_rate_data)

func set_lifetime_sec(new_lifetime_sec: float) -> void:
	lifetime_sec = maxf(new_lifetime_sec, MIN_LIFETIME_SEC)

func create_projectile(_from: Weapon, _to: Target, _cache: Array[Node3D] ) -> void:
	pass # (override this function)
