@tool
class_name Weapon extends Part

const MIN_BULLET_SPEED := 100.0

var bullet_speed := MIN_BULLET_SPEED:
	set = set_bullet_speed

var _min_angle := 0.0
var _max_angle := 0.0
var _projectile_data: ProjectileData

func set_bullet_speed(new_bullet_speed: float) -> void:
	bullet_speed = minf(MIN_BULLET_SPEED, new_bullet_speed)

func fire(target: Target) -> void:
	if _projectile_data == null:
		return
	var angle := get_angle_to(target.position)
	rotation = clampf(angle, _min_angle, _max_angle)
	_projectile_data.create_projectile(self, target)
