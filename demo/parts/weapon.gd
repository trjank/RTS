@tool
class_name Weapon extends Part

const MIN_BULLET_SPEED := 100.0

var bullet_speed := MIN_BULLET_SPEED:
	set = set_bullet_speed

var _min_angle := 0.0
var _max_angle := 0.0
var _projectile_data: ProjectileData

func _ship_init(ship_part: ShipDataPart, ship: Ship) -> void:
	super._ship_init(ship_part, ship)
	ship.target_changed.connect(fire)
	_projectile_data = ship_part.get_data().get_projectile()

func set_bullet_speed(new_bullet_speed: float) -> void:
	bullet_speed = minf(MIN_BULLET_SPEED, new_bullet_speed)

func fire(target: Target) -> void:
	if target == null or _projectile_data == null:
		return
	var angle := get_angle_to(target.position)
	global_rotation += angle + deg_to_rad(90.0)
	#rotation = clampf(angle, _min_angle, _max_angle)
	_projectile_data.create_projectile(self, target)
