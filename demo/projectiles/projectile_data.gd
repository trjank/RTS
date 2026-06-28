class_name ProjectileData extends PartData

const MIN_LIFETIME_SEC := 0.1

var damage := 0.0
var energy_drain := 0.0
var shield_penetration := 0.0
var lifetime_sec := MIN_LIFETIME_SEC:
	set = set_lifetime_sec

func set_lifetime_sec(new_lifetime_sec: float) -> void:
	lifetime_sec = maxf(new_lifetime_sec, MIN_LIFETIME_SEC)

func create_projectile(_from: Weapon, _to: Target, _cache: Array[Node3D] ) -> void:
	pass # (override this function)
