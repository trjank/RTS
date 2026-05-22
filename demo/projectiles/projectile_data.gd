class_name ProjectileData extends PartData

var damage := 0.0
var energy_drain := 0.0
var shield_penetration := 0.0
var lifetime_sec := 0.5

func create_projectile(_from: Weapon, _to: Target) -> void:
	pass # (override this function)
