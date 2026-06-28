class_name Weapon extends Part

var rest_angle := 0.0:
	set = set_rest_angle
var firing_arc := PI:
	set = set_firing_arc

var projectile_data: ProjectileData:
	set = set_projectile_data
var _projectiles: Array[Node3D] = []

func _ship_init(ship_part: ShipDataPart, ship: Ship) -> void:
	super._ship_init(ship_part, ship)
	#
	ship.target_changed.connect(fire)
	projectile_data = ship_part.get_data().get_projectile()

func set_projectile_data(new_projectile_data: ProjectileData) -> void:
	if projectile_data == new_projectile_data:
		return
	projectile_data = new_projectile_data
	_projectiles.clear()

func set_rest_angle(new_rest_angle: float) -> void:
	rest_angle = new_rest_angle
	rotation.y = rest_angle

func set_firing_arc(new_firing_arc: float) -> void:
	firing_arc = absf(new_firing_arc)
	rotation.y = rest_angle

func fire(target: Target) -> bool:
	if target == null or projectile_data == null:
		return false
	if false: # firing restrictions
		return false
	look_at(target.global_position)
	projectile_data.create_projectile(self, target, _projectiles)
	return true
