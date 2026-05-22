class_name Unit extends RigidBody3D

signal warped(from: Vector3, to: Vector3)

enum BehaviorFlags {
	NONE = 0,
	ATTACK = 1 << 0,
	FLEE = 1 << 1,
	TRACK = 1 << 2,
	BROADSIDE = 1 << 3,
	KITE = 1 << 4
}

const RAMMING_DISTANCE := 0.0
const BIG_NUMBER := 10_000.0
const MAX_NUM_WAYPOINTS := 5
const MOVE_LAZINESS := 1.0
const MIN_WARP_TURN_ANGLE := deg_to_rad(135.0)
const BROADSIDE_CORRECTION_ANGLE := deg_to_rad(100.0)
const HITBOX_RATIO := 0.5 * sqrt(2)

static var enable_warp_trails := true
static var color_cloak := Color.GREEN
static var color_selected := Color(1.0, 0.4, 0.4, 1.0)

static func create() -> Unit:
	return preload("res://battle/unit.tscn").instantiate()

@export var sprite: Sprite3D
@export var texture: Texture:
	set = set_texture
@export var torque_limit_curve: Curve
@export var broadside_curve: Curve
@export var hitbox: CollisionShape3D

var path_arc := 0.3
var value := 0.0
var hp := 1.0:
	set = set_hp
var warp := 500.0
var thrust := 0.0
var turnrate := 100.0
var player_owner: Player
var movement_locked := false
var size := Vector2.ZERO:
	set = set_size
var selected := false:
	set = set_selected
var warp_keep_momentum := false
var kill_credit: Player
var death_explosion := Explosion.DULL

var _stop_distance := 0.0
var _stop_rotation := 0.0
var _angle_to_waypoint := 0.0
var _angle_to_target := 0.0
var _direction_to_waypoint := Vector3.UP
var _direction_to_target := Vector3.UP
var _distance_to_waypoint := 0.0
var _distance_to_target := INF
var _time_to_turn := 0.0
var _time_to_move := 0.0
var _radar_signature := RadarSignature.new()
var _waypoints: Array[Target] = []
var _attack_position := Vector3.ZERO
var _behavior_flags: int = BehaviorFlags.NONE
var _internal_movement_locked := false
var _dying := false

## NOTE: This is useful for Array.map
static func to_radar_signature(unit: Unit) -> RadarSignature:
	return unit.get_radar_signature()

func _init() -> void:
	collision_layer = globals.Layer.UNITS

func _ready() -> void:
	_radar_signature._unit = self
	_radar_signature._state = RadarSignature.State.ALIVE
	sprite.pixel_size = Grid.METERS_PER_PX
	update_ui()

func _exit_tree() -> void:
	_radar_signature._unit = null
	_radar_signature._state = RadarSignature.State.DEAD

func is_moving() -> bool:
	return not movement_locked and not _internal_movement_locked and _time_to_turn <= path_arc * _time_to_move

func is_turning() -> bool:
	return absf(_angle_to_target) > absf(_stop_rotation)

func is_at_target() -> bool:
	return _distance_to_target <= MOVE_LAZINESS * _stop_distance

func is_queue_empty() -> bool:
	return _waypoints.is_empty()

func can_warp() -> bool:
	return (_distance_to_target <= warp and _waypoints.size() == 1) or MIN_WARP_TURN_ANGLE <= absf(_angle_to_target)

func get_behavior_flags() -> int:
	return _behavior_flags

func get_distance_to_target() -> float:
	return _distance_to_target

func get_distance_to_waypoint() -> float:
	return _distance_to_waypoint

func get_global_direction_to_target() -> Vector3:
	return _direction_to_target

func get_global_direction_to_waypoint() -> Vector3:
	return _direction_to_waypoint

func get_speed() -> float:
	return linear_velocity.length()

func get_torque_limit(angle := _angle_to_target) -> float:
	return torque_limit_curve.sample_baked(absf(angle) )

func get_forward_direction() -> Vector3:
	return -transform.basis.y

func get_global_forward_direction() -> Vector3:
	return -global_transform.basis.y

func get_waypoint(waypoint_num := 0) -> Target:
	return _waypoints[waypoint_num]

func get_attack_position() -> Vector3:
	return _attack_position

func get_radar_signature() -> RadarSignature:
	return _radar_signature

func get_max_speed() -> float:
	# NOTE: This comes from balancing forces:
	#    thrust = -F_drag
	# -> thrust = -mass * linear_damp * v_max
	# -> |v_max| = thrust / (mass * linear_damp)
	return thrust / (mass * linear_damp)

func get_max_angular_velocity() -> float:
	# NOTE: This comes from balancing forces:
	#    mass * turnrate = -F_drag
	# -> mass * turnrate = -mass * angular_damp * v_max
	# -> |v_max| = turnrate / angular_damp
	return turnrate / angular_damp

func set_size(new_size: Vector2) -> void:
	size = new_size
	update_ui()

func set_texture(new_texture: Texture) -> void:
	texture = new_texture
	update_ui()

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	update_ui()

func set_target(new_target: Target) -> bool:
	clear_waypoints()
	return queue_waypoint(new_target)

func set_hp(new_hp: float) -> void:
	hp = new_hp
	if hp <= 0:
		kill()

func hit(damage: float, from: Player = null) -> void:
	kill_credit = from
	hp -= damage

func drain_energy(_energy_drain: float) -> void:
	pass # (override this method)

func _update_hitbox() -> void:
	hitbox.shape.radius = HITBOX_RATIO * size[size.max_axis_index()]

func update_ui() -> void:
	if not is_node_ready():
		return
	sprite.texture = texture
	#sprite.pixel_size = size
	#sprite.modulate = color_selected if selected else Color.WHITE
	_update_hitbox()

func cloak() -> void:
	_radar_signature.state = RadarSignature.State.CLOAKED
	#modulate = color_cloak

func decloak() -> void:
	_radar_signature.state = RadarSignature.State.ALIVE
	#modulate = Color.WHITE

func clear_waypoints() -> void:
	_waypoints.clear()

func count_waypoints() -> int:
	return _waypoints.size()

## NOTE: i must be non-negative
func set_waypoint(i: int, waypoint: Target) -> bool:
	if waypoint == null or waypoint == self._radar_signature or i < 0 or _waypoints.size() <= i:
		return false
	_waypoints[i] = waypoint
	return true

func queue_waypoint(waypoint: Target) -> bool:
	if waypoint == null or waypoint == self._radar_signature:
		return false
	if MAX_NUM_WAYPOINTS <= _waypoints.size():
		return set_waypoint(_waypoints.size() - 1, waypoint)
	_waypoints.push_back(waypoint)
	sleeping = false
	return true

func pop_waypoint() -> void:
	if _waypoints.is_empty():
		return
	_behavior_flags = BehaviorFlags.NONE
	_distance_to_target = INF
	_waypoints.pop_front()

func kill() -> void:
	if kill_credit != null:
		kill_credit.register_kill(self)
	if player_owner != null:
		player_owner.register_loss(self)
	if death_explosion.is_empty() or not is_node_ready():
		queue_free()
	elif not _dying:
		#Explosion.explode(sprite, death_explosion, 3.0, 2.0, 0.0).connect(queue_free)
		_on_death_animation()
		_dying = true

func _on_death_animation() -> void:
	pass

func order_attack() -> void:
	attack()

## NOTE: This rams by default
func attack(min_distance := RAMMING_DISTANCE) -> void:
	_behavior_flags |= BehaviorFlags.ATTACK
	#
	_attack_position = get_waypoint().position
	_internal_movement_locked = _distance_to_waypoint <= min_distance

## NOTE: When safe_distance is reached, the current waypoint is popped
func flee(safe_distance := BIG_NUMBER) -> void:
	_behavior_flags |= BehaviorFlags.FLEE
	#
	_attack_position = get_waypoint().position - safe_distance * _direction_to_waypoint
	_internal_movement_locked = false

## NOTE: This is similar to attack(), but has better prediction for nukes and melee
func track() -> void:
	_behavior_flags |= BehaviorFlags.TRACK
	#
	var dt := _radar_signature.get_intersect_time(get_waypoint() )
	if dt <= 0:
		return attack()
	_attack_position = get_waypoint().get_intersection_point(dt)
	_internal_movement_locked = false

func broadside(distance: float, approach_angle := deg_to_rad(45.0) ) -> void:
	assert(approach_angle < deg_to_rad(90.0) )
	#
	_behavior_flags |= BehaviorFlags.BROADSIDE
	#
	var smooth_factor := broadside_curve.sample_baked(_distance_to_waypoint - distance)
	approach_angle = -signf(_angle_to_waypoint) * lerpf(BROADSIDE_CORRECTION_ANGLE, approach_angle, smooth_factor)
	_attack_position = global_position + BIG_NUMBER * _direction_to_waypoint.rotated(Vector3.UP, approach_angle)
	_internal_movement_locked = false

func kite(min_distance: float, max_distance: float) -> void:
	_behavior_flags |= BehaviorFlags.KITE
	#
	if _distance_to_waypoint < min_distance:
		return flee()
	attack(max_distance)

func _calculate_trajectory_to_target() -> void:
	var to_target := _attack_position - global_position
	_distance_to_target = to_target.length()
	_direction_to_target = to_target.normalized()
	_angle_to_target = get_global_forward_direction().angle_to(to_target)

func _calculate_trajectory_to_waypoint() -> void:
	var to_waypoint := get_waypoint().global_position - global_position
	_distance_to_waypoint = to_waypoint.length()
	_direction_to_waypoint = to_waypoint.normalized()
	_angle_to_waypoint = get_global_forward_direction().angle_to(to_waypoint)
	# NOTE: This comes from solving the differential equation:
	#    x'' = -damp * x' [This is how Godot calculates damp force]
	# -> x' = v_0 * exp(-damp * t)
	# -> x = x_0 + (v_0 / damp) * (1 - exp(-damp * t) )
	# -> x = x_0 + (v_0 / damp) [as t goes to infinity]
	# -> Δx = v_0 / damp
	_stop_distance = linear_velocity.dot(_direction_to_target) / linear_damp
	_stop_rotation = angular_velocity.y / angular_damp
	# This is just an approximation (but it works well in most cases)
	_time_to_move = _distance_to_target / get_max_speed()
	_time_to_turn = absf(_angle_to_target) / get_max_angular_velocity()

func _physics_process(_dt: float) -> void:
	_move_to_target()
	_update_radar_signature()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	assert(state.inverse_inertia.is_equal_approx(Vector3.ONE) )
	# Can treat torque as angular acceleration   ^^^^^^^^^^^
	if _waypoints.is_empty():
		return
	if is_turning():
		var torque := minf(turnrate, get_torque_limit() )
		state.apply_torque(signf(_angle_to_target) * torque * Vector3.UP)
	if is_moving():
		_warp_to_attack_position(state)
		state.apply_central_force(thrust * get_forward_direction() )

func _move_to_target() -> void:
	if _waypoints.is_empty():
		return
	if not get_waypoint().is_alive() or is_at_target():
		return pop_waypoint()
	_calculate_trajectory_to_waypoint()
	_behavior_flags = BehaviorFlags.NONE
	order_attack()
	_calculate_trajectory_to_target()

func _update_radar_signature() -> void:
	if _radar_signature.get_state() == RadarSignature.State.CLOAKED:
		return
	# TODO: Add any sort of radar jamming here
	_radar_signature.speed = get_speed()
	_radar_signature.linear_velocity = linear_velocity
	_radar_signature.global_position = global_position

func _create_warp_trail(from: Vector3, to: Vector3) -> void:
	if not enable_warp_trails:
		return
	#var warp_trail := WarpTrail.create()
	#add_sibling(warp_trail)
	#warp_trail.global_transform = Transform2D.IDENTITY
	#warp_trail.set_point_position(0, from)
	#warp_trail.set_point_position(1, to)

func _warp_to_attack_position(state: PhysicsDirectBodyState3D) -> void:
	if not can_warp():
		return
	if not warp_keep_momentum:
		state.linear_velocity = Vector3.ZERO
	var distance := minf(warp, _distance_to_target)
	var from := global_position
	var to := from + distance * _direction_to_target
	warp -= distance
	state.transform = global_transform.rotated(Vector3.UP, _angle_to_target)
	state.transform.origin = to
	_create_warp_trail(from, to)
	warped.emit(from, to)
