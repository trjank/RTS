class_name Weapon extends Part

const MIN_BULLET_SPEED := 100.0
const UP_ANGLE := deg_to_rad(-90.0)

var rest_angle := 0.0:
	set = set_rest_angle
var firing_arc := PI:
	set = set_firing_arc
var bullet_speed := MIN_BULLET_SPEED:
	set = set_bullet_speed

var _projectile_data: ProjectileData

func _ship_init(ship_part: ShipDataPart, ship: Ship) -> void:
	super._ship_init(ship_part, ship)
	ship.target_changed.connect(fire)
	_projectile_data = ship_part.get_data().get_projectile()

func set_rest_angle(new_rest_angle: float) -> void:
	rest_angle = new_rest_angle
	rotation.y = rest_angle

func set_firing_arc(new_firing_arc: float) -> void:
	firing_arc = absf(new_firing_arc)
	rotation.y = rest_angle

func set_bullet_speed(new_bullet_speed: float) -> void:
	bullet_speed = minf(MIN_BULLET_SPEED, new_bullet_speed)

func fire(target: Target) -> bool:
	if target == null or _projectile_data == null:
		return false
	look_at(target.global_position)
	#var angle := rotation.y + get_angle_to(target.position) - UP_ANGLE
	#if absf(angle_difference(angle, rest_angle) ) > firing_arc:
		#return false
	#rotation = angle
	_projectile_data.create_projectile(self, target)
	return true
