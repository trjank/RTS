class_name Unit extends RigidBody3D

# NOTE: When you update mass, you need to call update_inertia_tensor() afterwards

signal warped(from: Vector3, to: Vector3)
signal died

enum Behavior {
	NONE = 0,
	ATTACK = 1 << 0,
	FLEE = 1 << 1,
	TRACK = 1 << 2,
	BROADSIDE = 1 << 3,
	KITE = 1 << 4
}

const MAX_NUM_WAYPOINTS := 10
const RAMMING_DISTANCE := 0.0
const DEFAULT_SAFE_DISTANCE := 10_000.0
const BROADSIDE_DISTANCE := 10_000.0
const BROADSIDE_CORRECTION_ANGLE := deg_to_rad(100.0)
const HITBOX_SIZE_RATIO := 0.5 * sqrt(2)
const WARP_TRAIL_DURATION_SEC := 1.0

static var WARP_TRAIL := TrailData.new():
	set(__): push_error("(Unit) Unit.WARP_TRAIL is immutable!")
static var warp_trails_enabled := true
static var color_cloak := Color.GREEN
static var color_selected := Color(1.0, 0.4, 0.4, 1.0)

static func create() -> Unit:
	return preload("res://units/unit.tscn").instantiate()

@export var sprite: Sprite3D
@export var texture: Texture:
	set = set_texture
@export var broadside_curve: Curve
@export var hitbox: CollisionShape3D

var value := StrategicResources.NONE
var path_arc := 0.3
var course_correction := 3.0
var hp := 1.0:
	set = set_hp
var warp := 0.0
var thrust := 0.0
var torque := 10000.0
var player_owner: Player:
	set = set_player_owner
var movement_locked := false
var size := Vector2.ZERO:
	set = set_size
var selected := false:
	set = set_selected
var warp_keep_momentum := false
var kill_credit: Player

var _stop_distance := 0.0
var _stop_rotation := 0.0
var _quaternion_to_waypoint := Quaternion.IDENTITY
var _quaternion_to_target := Quaternion.IDENTITY
var _direction_to_waypoint := Vector3.UP
var _direction_to_target := Vector3.UP
var _distance_to_waypoint := 0.0
var _distance_to_target := INF
var _time_to_turn := 0.0
var _time_to_move := 0.0
var _radar_signature := RadarSignature.new()
var _waypoints: Array[Target] = []
var _attack_position := Vector3.ZERO
var _behavior_flags: int = Behavior.NONE
var _internal_movement_locked := false

## NOTE: This is useful for Array.map
static func to_radar_signature(unit: Unit) -> RadarSignature:
	return unit.get_radar_signature() if unit != null else null

func _ready() -> void:
	_radar_signature._unit = self
	_radar_signature._state = RadarSignature.State.ALIVE
	sprite.pixel_size = Measurement.METERS_PER_PX
	update_ui()
	#
	collision_layer = globals.Layer.UNITS | globals.Layer.SCENERY
	collision_mask = globals.Layer.UNITS | globals.Layer.SCENERY

func _exit_tree() -> void:
	_radar_signature._unit = null
	_radar_signature._state = RadarSignature.State.DEAD

func is_moving() -> bool:
	return not movement_locked and not _internal_movement_locked and _time_to_turn <= path_arc * _time_to_move and _distance_to_target > _stop_distance

func is_turning() -> bool:
	return _quaternion_to_target.get_angle() > _stop_rotation

func is_at_target() -> bool:
	return _distance_to_target <= _stop_distance

func is_queue_empty() -> bool:
	return _waypoints.is_empty()

func can_warp() -> bool:
	return not is_queue_empty() and get_waypoint().is_warp_point and _distance_to_target <= warp

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

func get_forward_direction() -> Vector3:
	return -transform.basis.z

func get_global_forward_direction() -> Vector3:
	return -global_transform.basis.z

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
	#    torque = -T_drag
	# -> torque = -mass * angular_damp * ω_max
	# -> |ω_max| = turnrate / (mass * angular_damp)
	return torque / (mass * angular_damp)

func set_player_owner(new_player_owner: Player) -> void:
	player_owner = new_player_owner

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

func hit(damage: float, from: Player = null, _penetration := 0.0) -> void:
	kill_credit = from
	hp -= damage

func drain_energy(_energy_drain: float) -> void:
	pass # (override this method)

func find_nearest(_predicate: Callable) -> Node:
	return null

func find_near(_predicate: Callable) -> Array[Node]:
	return []

func update_inertia_tensor() -> void:
	# This makes the mass distribution sphere-like, but not affected by radius
	inertia = Vector3(mass, mass, mass)

func _update_hitbox() -> void:
	hitbox.shape.radius = HITBOX_SIZE_RATIO * size[size.max_axis_index() ]

func update_ui() -> void:
	if not is_node_ready():
		return
	sprite.texture = texture
	_update_hitbox()

func cloak() -> void:
	_radar_signature.state = RadarSignature.State.CLOAKED

func decloak() -> void:
	_radar_signature.state = RadarSignature.State.ALIVE

func clear_waypoints() -> void:
	_waypoints.clear()

func count_waypoints() -> int:
	return _waypoints.size()

func queue_waypoint(waypoint: Target) -> bool:
	if waypoint == null or waypoint == self._radar_signature:
		return false
	if MAX_NUM_WAYPOINTS <= _waypoints.size():
		_waypoints[-1] = waypoint
	else:
		_waypoints.push_back(waypoint)
		sleeping = false
	return true

func pop_waypoint() -> bool:
	_behavior_flags = Behavior.NONE
	_distance_to_target = INF
	return _waypoints.pop_front() != null

func kill() -> void:
	if is_queued_for_deletion():
		return
	if kill_credit != null:
		kill_credit.register_kill(self)
	if player_owner != null:
		player_owner.register_death(self)
	queue_free()
	died.emit()

func order_attack() -> void:
	attack()

func is_near() -> bool:
	return true

func issue_command(behavior: Behavior, arg1 := 0.0, arg2 := 0.0) -> bool:
	match behavior:
		Behavior.ATTACK: attack(arg1)
		Behavior.FLEE: flee(arg1)
		Behavior.TRACK: track()
		Behavior.BROADSIDE: broadside(arg1, arg2)
		Behavior.KITE: kite(arg1, arg2)
		_: return false # (do not pass multiple flags)
	return true

## NOTE: This rams by default
func attack(min_distance := RAMMING_DISTANCE) -> void:
	_behavior_flags |= Behavior.ATTACK
	#
	_attack_position = get_waypoint().global_position
	_internal_movement_locked = _distance_to_waypoint <= min_distance

## NOTE: When safe_distance is reached, the current waypoint is popped
func flee(safe_distance := DEFAULT_SAFE_DISTANCE) -> void:
	_behavior_flags |= Behavior.FLEE
	#
	_attack_position = get_waypoint().position - safe_distance * _direction_to_waypoint
	_internal_movement_locked = false

## NOTE: This is similar to attack(), but has better prediction for nukes and melee
func track() -> void:
	_behavior_flags |= Behavior.TRACK
	#
	var dt := _radar_signature.get_intersect_time(get_waypoint() )
	if dt <= 0:
		return attack()
	_attack_position = get_waypoint().get_intersection_point(dt)
	_internal_movement_locked = false

func broadside(distance: float, approach_angle := deg_to_rad(45.0) ) -> void:
	assert(approach_angle < deg_to_rad(90.0) )
	#
	_behavior_flags |= Behavior.BROADSIDE
	#
	var smooth_factor := broadside_curve.sample_baked(_distance_to_waypoint - distance)
	approach_angle = _quaternion_to_target.get_angle() * lerpf(BROADSIDE_CORRECTION_ANGLE, approach_angle, smooth_factor)
	_attack_position = global_position + BROADSIDE_DISTANCE * _direction_to_waypoint.rotated(Vector3.UP, approach_angle)
	_internal_movement_locked = false

func kite(min_distance: float, max_distance: float) -> void:
	_behavior_flags |= Behavior.KITE
	#
	if _distance_to_waypoint < min_distance:
		return flee()
	attack(max_distance)

func _calculate_trajectory_to_waypoint() -> void:
	var to_waypoint := get_waypoint().global_position - global_position
	_distance_to_waypoint = to_waypoint.length()
	_direction_to_waypoint = to_waypoint.normalized()
	_quaternion_to_waypoint = Quaternion(get_global_forward_direction(), to_waypoint)

func _course_correct(to_target: Vector3, to_target_speed: float) -> void:
	# If the direction of travel is not straight, turn more to course correct
	var perp_velocity := linear_velocity - to_target_speed * _direction_to_target
	var correction := course_correction * perp_velocity * _time_to_move
	_quaternion_to_target = Quaternion(get_global_forward_direction(), to_target - correction)

func _calculate_trajectory_to_target() -> void:
	var to_target := _attack_position - global_position
	_distance_to_target = to_target.length()
	_direction_to_target = to_target.normalized()
	var to_target_speed := linear_velocity.dot(_direction_to_target)
	_quaternion_to_target = Quaternion(get_global_forward_direction(), to_target)
	# NOTE: This comes from solving the differential equation:
	#    x'' = -damp * x' [This is how Godot calculates damp force]
	# -> x' = v_0 * exp(-damp * t)
	# -> x = x_0 + (v_0 / damp) * (1 - exp(-damp * t) )
	# -> x = x_0 + (v_0 / damp) [as t goes to infinity]
	# -> Δx = v_0 / damp
	_stop_distance = to_target_speed / linear_damp
	_stop_rotation = angular_velocity.length() / angular_damp
	# This is just an approximation (but it works well in most cases)
	_time_to_move = _distance_to_target / get_max_speed()
	_time_to_turn = _quaternion_to_target.get_angle() / get_max_angular_velocity()
	_course_correct(to_target, to_target_speed)

func _physics_process(_dt: float) -> void:
	_update_radar_signature()

func _turn_to_target(state: PhysicsDirectBodyState3D) -> void:
	# NOTE: This comes from solving the inequality:
	#    stop_rotation <= Δθ
	# -> ω / angular_damp <= Δθ
	# -> ω <= angular_damp * Δθ
	# -> ω_0 + Δω <= angular_damp * Δθ
	# -> Δω <= angular_damp * Δθ - ω_0
	var deviation := angular_damp * _quaternion_to_target.get_angle() - angular_velocity.length()
	# Since inertia tensor is the identity multiplied by mass, we can easily convert to torque
	var max_torque := mass * deviation / state.step
	# Need to limit torque because time steps are discrete (and can overshoot target)
	state.apply_torque(minf(torque, max_torque) * _quaternion_to_target.get_axis() )

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _calculate_trajectory():
		return
	if is_moving():
		_warp_to_attack_position(state)
		state.apply_central_force(thrust * get_forward_direction() )
	if is_turning():
		_turn_to_target(state)

func _calculate_trajectory() -> bool:
	if _waypoints.is_empty():
		return false
	if not get_waypoint().is_alive() or is_at_target():
		return not pop_waypoint()
	_calculate_trajectory_to_waypoint()
	_behavior_flags = Behavior.NONE
	order_attack()
	_calculate_trajectory_to_target()
	return true

func _update_radar_signature() -> void:
	if _radar_signature.get_state() == RadarSignature.State.CLOAKED:
		return
	# TODO: Add any sort of radar jamming here
	_radar_signature.speed = get_speed()
	_radar_signature.linear_velocity = linear_velocity
	_radar_signature.global_position = global_position

func _create_warp_trail(from: Vector3, to: Vector3) -> void:
	if not warp_trails_enabled:
		return
	var trail := Trail.create()
	add_sibling(trail)
	trail.data = WARP_TRAIL
	trail.move(from, to)
	trail.pulse(WARP_TRAIL_DURATION_SEC)
	get_tree().create_timer(WARP_TRAIL_DURATION_SEC).timeout.connect(trail.queue_free)

func _warp_to_attack_position(state: PhysicsDirectBodyState3D) -> void:
	if not can_warp():
		return
	if not warp_keep_momentum:
		state.linear_velocity = Vector3.ZERO
	var distance := minf(warp, _distance_to_target)
	var from := global_position
	var to := from + distance * _direction_to_target
	warp -= distance
	state.transform.origin = to
	_create_warp_trail(from, to)
	warped.emit(from, to)
