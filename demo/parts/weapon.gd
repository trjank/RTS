class_name Weapon extends Part

enum TargetError {
	OK,
	INVALID_DATA,
	NOT_IN_RANGE,
	NOT_IN_ARC
}

var projectile_data: ProjectileData:
	set = set_projectile_data
var arc := 0.0:
	set = set_arc
var modifiers := WeaponModifiers.NONE:
	set = set_modifiers
var target_prediction := true

# This is an optional cache to reuse projectiles
var _projectiles: Array[Node3D] = []

func _ready() -> void:
	render_priority = 3

func is_valid_rotation(rotation_y: float) -> bool:
	return absf(rotation_y) <= 0.5 * arc

func get_barrel_position() -> Vector3:
	return Vector3(0.0, 0.0, -Measurement.METERS_PER_TILE * get_data().barrel_z)

func get_global_barrel_position() -> Vector3:
	return to_global(get_barrel_position() )

func get_data() -> WeaponData:
	return data

func set_data(new_data: PartData) -> void:
	super(new_data as WeaponData)
	#
	offset.y = -Measurement.PX_PER_TILE * get_data().center_z if data != null else 0.0

func set_arc(new_arc: float) -> void:
	arc = absf(new_arc)
	rotation.y = 0.0

func set_modifiers(new_modifiers: WeaponModifiers) -> void:
	modifiers = new_modifiers if new_modifiers != null else WeaponModifiers.NONE

func set_projectile_data(new_projectile_data: ProjectileData) -> void:
	if projectile_data == new_projectile_data:
		return
	projectile_data = new_projectile_data
	_projectiles.clear()

func on_ship_ready(ship_part: ShipDataPart, ship: Ship) -> void:
	super(ship_part, ship)
	#
	var ship_weapon: ShipDataWeapon = ship_part
	update_projectile()
	update_mount(ship_weapon.get_mount() )
	ship.target_changed.connect(fire)

func update_projectile() -> void:
	assert(data != null)
	#
	projectile_data = get_data().get_projectile()
	target_prediction = get_data().target_prediction

func update_mount(new_mount: ShipDataWeaponMount) -> void:
	arc = deg_to_rad(new_mount.get_data().arc_degrees) if new_mount != null else 0.0
	modifiers = new_mount.get_modifiers() if new_mount != null else WeaponModifiers.NONE

func calculate_target_position(target: Target) -> Vector3:
	if not target_prediction:
		return target.global_position
	var time := target.get_approx_intersect_time_from(global_position, projectile_data.get_speed() )
	return target.get_intersection_point(time)

func create_muzzle_flash() -> void:
	if not get_data().muzzle_flash_enabled or battle == null:
		return
	var shockwave := battle.shockwaves.create_shockwave_at(get_global_barrel_position() )
	shockwave.duration_sec = 0.5
	shockwave.distortion = 0.1
	#var explosion_transform := Transform3D(global_basis, get_global_barrel_position() )
	#var explosion := battle.explosions.create_explosion(get_data().muzzle_flash, explosion_transform)
	#get_data().muzzle_flash.glow = 50.0
	#get_data().muzzle_flash.skew = 1.0
	#get_data().muzzle_flash.color = Color.ORANGE_RED
	#explosion.start_radius = 0.5
	#explosion.duration_sec = 0.5

func fire(target: Target) -> TargetError:
	if target == null or projectile_data == null or data == null:
		return TargetError.INVALID_DATA
	var target_position := calculate_target_position(target)
	var local := to_local(target_position)
	var new_rotation := rotation.y + atan2(-local.x, -local.z)
	# NOTE: The center is used to check distance (not barrel position)
	if not is_valid_rotation(new_rotation):
		return TargetError.NOT_IN_ARC
	if target_position.distance_to(global_position) > projectile_data.effective_range:
		return TargetError.NOT_IN_RANGE
	rotation.y = new_rotation
	projectile_data.create_projectile(self, target, _projectiles)
	create_muzzle_flash()
	return TargetError.OK
