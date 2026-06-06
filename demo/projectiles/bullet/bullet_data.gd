class_name BulletData extends ProjectileData

const MIN_MISSILE_TORQUE = 0.1

var launch_velocity := 0.0
var linear_damp := 0.0

func is_missile() -> bool:
	return MIN_MISSILE_TORQUE <= torque

func create_projectile(from: Weapon, to: Target) -> void:
	assert(from != null)
	#
	var bullet := Bullet.create()
	var ship := from.get_ship()
	var velocity := from.get_global_forward_direction() * launch_velocity
	bullet.data = self
	bullet.linear_velocity = velocity.rotated(Vector3.UP, ship.get_parent().global_rotation.y)
	ship.add_sibling(bullet)
	bullet.begin_death_timer()
	bullet.global_position = from.global_position
	bullet.look_at(to.position)
