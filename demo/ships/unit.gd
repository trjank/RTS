class_name Unit extends RigidBody2D

const MAX_NUM_WAYPOINTS := 5
const TURN_JERKINESS := 10.0
const PATH_WIDTH := 1.0
const MOVE_LAZINESS := 1.0

static var cloak_color := Color.GREEN
static var selected_color := Color.RED

signal warped(from: Vector2, to: Vector2)

var path_arc := 0.1
var value := 0.0
var hp := 0.0:
	set = set_hp
var warp := 500.0
var thrust := 500.0
var speed: float:
	get = get_speed
var turnrate := 1.0
var player_owner: Player
var movement_locked := false
var selected := false
var kill_credit: Player

var _stop_distance := 0.0
var _thrusters_active := false
var _angle_to_target := 0.0
var _time_to_turn := 0.0
var _time_to_move := 0.0
var _distance_to_target := 0.0
var _radar_signature := RadarSignature.new()
var _waypoints: Array[Target] = []
var _attack_position := Target.new()
var _path: Line2D
var _image: Sprite2D

func _ready() -> void:
	_radar_signature.unit = self
	_radar_signature.state = RadarSignature.State.ALIVE
	_path.add_point(Vector2.ZERO)
	_path.texture_mode = Line2D.LineTextureMode.LINE_TEXTURE_TILE
	_path.texture_repeat = CanvasItem.TextureRepeat.TEXTURE_REPEAT_ENABLED
	angular_damp = 0.0
	gravity_scale = 0.0

func _exit_tree() -> void:
	_radar_signature.unit = null
	_radar_signature.state = RadarSignature.State.DEAD

func get_speed() -> float:
	return linear_velocity.length()

func set_hp(new_hp: float) -> void:
	if new_hp <= 0:
		hp = 0.0
		kill()
	else:
		hp = new_hp

func hit(damage: float, from: Player = null) -> void:
	kill_credit = from
	hp -= damage

func get_forward_direction() -> Vector2:
	return -transform.y

func get_waypoint(waypoint_num := 0) -> Target:
	return _waypoints[waypoint_num]

func get_attack_position() -> Target:
	return _attack_position

# NOTE: Do not modify the radar signature while using it
func get_radar_signature() -> RadarSignature:
	return _radar_signature

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	_path.visible = is_selected
	_image.self_modulate = selected_color if is_selected else Color.WHITE

func set_texture(new_texture: Texture2D) -> void:
	_image.set_texture(new_texture)
	_image.reset_to_default_size()

func cloak() -> void:
	_radar_signature.state = RadarSignature.State.CLOAKED
	modulate = cloak_color

func decloak() -> void:
	_radar_signature.state = RadarSignature.State.ALIVE
	modulate = Color.WHITE

func kill() -> void:
	if kill_credit != null:
		kill_credit.team.register_kill(self)
		player_owner.team.register_loss(self)
	queue_free()

func clear_movement_queue() -> void:
	_waypoints.clear()
	_path.clear_points()
	_path.add_point(global_position)

func queue_waypoint(waypoint: Target) -> bool:
	if waypoint == null:
		return false
	if _waypoints.size() >= MAX_NUM_WAYPOINTS:
		_waypoints.pop_back()
	# Add the point twice to prevent linecap distortion
	_path.add_point(waypoint.position)
	_path.add_point(waypoint.position)
	_waypoints.push_back(waypoint)
	return true

func set_target(new_target: Target) -> void:
	# Placeholder behavior: move to target
	clear_movement_queue()
	queue_waypoint(new_target)

func order_attack() -> void:
	ram(get_waypoint())

func pop_waypoint() -> Target:
	if _waypoints.is_empty():
		return null
	_path.remove_point(2)
	_path.remove_point(1)
	return _waypoints.pop_front()

func _physics_process(_dt: float) -> void:
	_move_to_target()
	_update_radar_signature()
	#_update_path()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _waypoints.is_empty():
		state.angular_velocity = 0.0
		return
	if _thrusters_active:
		state.apply_central_force(thrust * get_forward_direction())
	var turn_direction := clampf(TURN_JERKINESS * _angle_to_target, -1.0, 1.0)
	state.angular_velocity = turnrate * turn_direction
	if _thrusters_active and _distance_to_target <= warp:
		_warp_to_attack_position(state)

func move_to(new_position: Vector2) -> void:
	_attack_position.position = new_position

func ram(target: Target) -> void:
	move_to(target.get_position())

func flee(target: Target, safe_distance: float) -> void:
	var direction := (global_position - target.position).normalized()
	move_to(global_position + safe_distance * direction)

func track(target: Target) -> void:
	var time_intersect := _radar_signature.get_intersect_time(target)
	if time_intersect == Target.NO_INTERSECTION:
		ram(target)
	else:
		move_to(target.get_intersection_point(time_intersect))

func kite(target: Target, min_distance: float, max_distance: float) -> void:
	if _distance_to_target < min_distance:
		flee(target, max_distance)
		movement_locked = false
	elif _distance_to_target > max_distance:
		ram(target)
		movement_locked = false
	else:
		movement_locked = true

func update_path() -> void:
	_path.global_rotation = 0.0
	_path.global_position = Vector2.ZERO
	_path.set_point_position(0, global_position)

func _update_attack_info() -> void:
	var dx := _attack_position.position - global_position
	_distance_to_target = dx.length()
	_angle_to_target = get_forward_direction().angle_to(dx)
	_stop_distance = linear_velocity.dot(dx.normalized()) / linear_damp
	_time_to_move = _distance_to_target / speed
	_time_to_turn = absf(_angle_to_target / turnrate)

func _move_to_target() -> void:
	if _waypoints.is_empty():
		return
	order_attack()
	_update_attack_info()
	_thrusters_active = not movement_locked and _time_to_turn <= path_arc * _time_to_move
	if _distance_to_target <= MOVE_LAZINESS * _stop_distance:
		pop_waypoint()

func _update_radar_signature() -> void:
	if _radar_signature.state == RadarSignature.State.CLOAKED:
		return
	_radar_signature.speed = speed
	_radar_signature.velocity = linear_velocity
	_radar_signature.position = global_position

func _warp_to_attack_position(state: PhysicsDirectBodyState2D) -> void:
	warp -= _distance_to_target
	rotation += _angle_to_target
	state.global_position = _attack_position.position
	state.linear_velocity = Vector2.ZERO
	warped.emit(global_position, _attack_position.position)
