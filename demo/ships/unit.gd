class_name Unit extends RigidBody2D

signal warped(from: Vector2, to: Vector2)

enum Behavior {
	RAM,
	FLEE,
	TRACK,
	KITE
}

const MAX_NUM_WAYPOINTS := 5
const MOVE_LAZINESS := 1.0
const MIN_WARP_TURN_ANGLE := deg_to_rad(135.0)

static var enable_warp_trails := true
static var color_cloak := Color.GREEN
static var color_selected := Color.RED

static func create() -> Unit:
	return preload("res://ships/unit.tscn").instantiate()

# DO NOT EDIT PATH POINTS AT ALL!
@export var path: Line2D
@export var sprite: ResizeableSprite2D
@export var texture: Texture:
	set = set_texture
@export var torque_limit_curve: Curve

var path_arc := 0.3
var value := 0.0
var hp := 0.0:
	set = set_hp
var warp := 500.0
var thrust := 10000.0
var turnrate := 10.0
var player_owner: Player
var movement_locked := false
var selected := true:
	set = set_selected
var warp_keep_momentum := true
var kill_credit: Player

var _stop_distance := 0.0
var _stop_rotation := 0.0
var _angle_to_target := 0.0
var _direction_to_target: Vector2
var _time_to_turn := 0.0
var _time_to_move := 0.0
var _distance_to_target := 0.0
var _radar_signature := RadarSignature.new()
var _waypoints: Array[Target] = []
var _attack_position := Target.new()
var _behavior := Behavior.RAM

func _ready() -> void:
	_radar_signature._unit = self
	_radar_signature._state = RadarSignature.State.ALIVE
	update_ui()

func _exit_tree() -> void:
	_radar_signature._unit = null
	_radar_signature._state = RadarSignature.State.DEAD

func is_moving() -> bool:
	return not movement_locked and _time_to_turn <= path_arc * _time_to_move

func is_turning() -> bool:
	return absf(_angle_to_target) > absf(_stop_rotation)

func is_at_target() -> bool:
	return _distance_to_target <= MOVE_LAZINESS * _stop_distance

func can_warp() -> bool:
	return _distance_to_target <= warp or MIN_WARP_TURN_ANGLE <= absf(_angle_to_target)

func get_behavior() -> Behavior:
	return _behavior

func get_speed() -> float:
	return linear_velocity.length()

func get_torque_limit(angle := _angle_to_target) -> float:
	return torque_limit_curve.sample_baked(absf(angle) )

func get_forward_direction() -> Vector2:
	return -transform.y

func get_global_forward_direction() -> Vector2:
	return -global_transform.y

func get_waypoint(waypoint_num := 0) -> Target:
	return _waypoints[waypoint_num]

func get_attack_position() -> Target:
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

func set_texture(new_texture: Texture) -> void:
	texture = new_texture
	update_ui()

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	update_ui()

func set_target(new_target: Target) -> void:
	clear_waypoints()
	queue_waypoint(new_target)

func set_hp(new_hp: float) -> void:
	hp = new_hp
	if new_hp <= 0:
		kill()

func hit(damage: float, from: Player = null) -> void:
	kill_credit = from
	hp -= damage

func update_ui() -> void:
	if not is_node_ready():
		return
	sprite.texture = texture
	sprite.modulate = color_selected if selected else Color.WHITE
	path.visible = selected

func cloak() -> void:
	_radar_signature.state = RadarSignature.State.CLOAKED
	modulate = color_cloak

func decloak() -> void:
	_radar_signature.state = RadarSignature.State.ALIVE
	modulate = Color.WHITE

func clear_waypoints() -> void:
	_waypoints.clear()
	_clear_path()

func set_waypoint(waypoint: Target, i := 0) -> void:
	if i < 0 or _waypoints.size() < i:
		return
	_waypoints[i] = waypoint
	_update_path_point(i + 1, waypoint)

func queue_waypoint(waypoint: Target) -> void:
	if waypoint == null:
		return
	if MAX_NUM_WAYPOINTS <= _waypoints.size():
		return set_waypoint(waypoint, _waypoints.size() - 1)
	_add_path_point(waypoint)
	_waypoints.push_back(waypoint)

func pop_waypoint() -> Target:
	if _waypoints.is_empty():
		return null
	_remove_path_point(1)
	return _waypoints.pop_front()

func order_attack() -> void:
	ram(get_waypoint() )

func kill() -> void:
	if kill_credit != null:
		kill_credit.register_kill(self)
	if player_owner != null:
		player_owner.register_loss(self)
	queue_free()

func _physics_process(_dt: float) -> void:
	_move_to_target()
	_update_radar_signature()
	_update_path()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	assert(is_equal_approx(state.inverse_inertia, 1.0) )
	#   Allows us to treat torque as acceleration ^^^
	if _waypoints.is_empty():
		return
	if is_turning():
		var torque := minf(turnrate, get_torque_limit() )
		state.apply_torque(signf(_angle_to_target) * torque)
	if is_moving():
		_warp_to_attack_position(state)
		state.apply_central_force(thrust * get_forward_direction() )

func ram(target: Target) -> void:
	_behavior = Behavior.RAM
	_attack_position.position = target.position

func flee(target: Target, safe_distance: float) -> void:
	var direction := (global_position - target.position).normalized()
	_behavior = Behavior.FLEE
	_attack_position.position = global_position + safe_distance * direction

func track(target: Target) -> void:
	var dt := _radar_signature.get_intersect_time(target)
	if dt == Target.NO_INTERSECTION:
		return ram(target)
	_behavior = Behavior.TRACK
	_attack_position.position = target.get_intersection_point(dt)

func circle(target: Target) -> void:
	pass

func kite(target: Target, min_distance: float, max_distance: float) -> void:
	if _distance_to_target < min_distance:
		flee(target, max_distance)
		movement_locked = false
	elif _distance_to_target > max_distance:
		ram(target)
		movement_locked = false
	else:
		movement_locked = true

func _clear_path() -> void:
	path.clear_points()
	path.add_point(global_position)

func _add_path_point(target: Target) -> void:
	# NOTE: Duplicate points prevent linecap distortion
	path.add_point(target.position)
	path.add_point(target.position)

func _update_path_point(i: int, target: Target) -> void:
	# NOTE: Duplicate points prevent linecap distortion
	path.set_point_position(2 * i - 1, target.position)
	path.set_point_position(2 * i, target.position)

func _remove_path_point(i: int) -> void:
	# NOTE: Duplicate points prevent linecap distortion
	path.remove_point(2 * i)
	path.remove_point(2 * i - 1)

func _update_path() -> void:
	if not path.visible:
		return
	for i in _waypoints.size():
		_update_path_point(i + 1, _waypoints[i] )
	path.set_point_position(0, global_position)
	path.global_transform = Transform2D.IDENTITY

func _calculate_trajectory() -> void:
	var dx := _attack_position.position - global_position
	_direction_to_target = dx.normalized()
	_distance_to_target = dx.length()
	_angle_to_target = get_global_forward_direction().angle_to(dx)
	# NOTE: This comes from solving the differential equation:
	#    x'' = -damp * x'
	# -> x' = v_0 * exp(-damp * t)
	# -> x = x_0 + (v_0 / damp) * (1 - exp(-damp * t) )
	# -> x = x_0 + (v_0 / damp) [as t goes to infinity]
	# -> Δx = v_0 / damp
	_stop_distance = linear_velocity.dot(_direction_to_target) / linear_damp
	_stop_rotation = angular_velocity / angular_damp
	# NOTE: This is just an approximation (but it works well in most cases)
	_time_to_move = _distance_to_target / get_max_speed()
	_time_to_turn = absf(_angle_to_target) / get_max_angular_velocity()

func _move_to_target() -> void:
	if _waypoints.is_empty():
		return
	order_attack()
	_calculate_trajectory()
	if is_at_target() or not get_waypoint().is_alive():
		pop_waypoint()

func _update_radar_signature() -> void:
	if _radar_signature.get_state() == RadarSignature.State.CLOAKED:
		return
	# TODO: Add any sort of radar jamming here
	_radar_signature.speed = get_speed()
	_radar_signature.velocity = linear_velocity
	_radar_signature.position = global_position

func _create_warp_trail(from: Vector2, to: Vector2) -> void:
	if not enable_warp_trails:
		return
	var warp_trail := WarpTrail.create()
	add_sibling(warp_trail)
	warp_trail.global_transform = Transform2D.IDENTITY
	warp_trail.set_point_position(0, from)
	warp_trail.set_point_position(1, to)

func _warp_to_attack_position(state: PhysicsDirectBodyState2D) -> void:
	if not can_warp():
		return
	if not warp_keep_momentum:
		state.linear_velocity = Vector2.ZERO
	var distance := minf(warp, _distance_to_target)
	var from := global_position
	var to := from + distance * _direction_to_target
	warp -= distance
	state.transform = global_transform.rotated(_angle_to_target)
	state.transform.origin = to
	_create_warp_trail(from, to)
	warped.emit(from, to)
