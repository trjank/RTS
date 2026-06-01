class_name Planet extends Orbiter

const LABEL_OFFSET_METERS := 2.0
const MIN_RADIUS := 0.0
const MAX_RADIUS := 100.0

@export var always_upright: Node3D
@export var label: Label3D
@export var mesh_instance: MeshInstance3D
@export var zone: Area3D
@export var zone_shape: CollisionShape3D

var capturable := true:
	set = set_capturable
var alloy_per_sec := 0.0
var energy_per_sec := 0.0
var capture_progress := 0.0
var display_name: String:
	set = set_display_name
var radius := MIN_RADIUS:
	set = set_radius

var _team_owner: Team
var _team_ship_count: Dictionary[Team, int] = {}

static func _ship_to_team(ship: Ship) -> Team:
	return ship.player_owner.team if ship.player_owner != null else null

func is_contested() -> bool:
	return _team_ship_count.size() > 1

func is_captured() -> bool:
	return _team_owner != null

func get_team_owner() -> Team:
	return _team_owner

func count_capturing_ships(team: Team) -> int:
	return _team_ship_count.get(team, 0)

func set_radius(new_radius: float) -> void:
	radius = clampf(new_radius, MIN_RADIUS, MAX_RADIUS)
	zone_shape.shape.radius = radius
	label.position.z = -radius - LABEL_OFFSET_METERS
	# NOTE: Ensure the mesh's size is one for this to work
	mesh_instance.scale = radius * Vector3.ONE

func set_display_name(new_display_name: String) -> void:
	display_name = new_display_name
	label.text = display_name if is_zero_approx(alloy_per_sec) else "%s | %.1f" % [display_name, alloy_per_sec]

func set_capturable(is_capturable: bool) -> void:
	capturable = is_capturable
	zone_shape.disabled = not is_capturable

func _process(dt: float) -> void:
	super(dt)
	#
	always_upright.global_rotation = Vector3.ZERO

func _ready() -> void:
	super()
	#
	var min_radius := float(_map.preset.get("min_radius", MIN_RADIUS) )
	var max_radius := float(_map.preset.get("max_radius", MAX_RADIUS) )
	capturable = _map.preset.get("capturable", true)
	radius = _rng.randf_range(min_radius, max_radius)
	display_name = _map.preset.get("display_name", "")
	always_upright.position = Vector3.ZERO

func _update_team_owner() -> void:
	_team_ship_count.clear()
	_team_owner = null
	#
	for team in zone.get_overlapping_bodies().map(_ship_to_team):
		_team_ship_count[team] = _team_ship_count.get(team, 0) + 1
	for team in _team_ship_count:
		_team_owner = team if _team_owner == null or _team_ship_count[team] > _team_ship_count[_team_owner] else _team_owner

func recalculate_capture_progress() -> void:
	var old_team_owner := _team_owner
	_update_team_owner()
	if old_team_owner == _team_owner:
		return
	if _team_owner != null:
		_team_owner.register_capture(self)
	if old_team_owner != null:
		old_team_owner.register_loss(self)

func _on_area_3d_body_entered(body: Node3D) -> void:
	assert(body is Ship)
	#
	recalculate_capture_progress()

func _on_area_3d_body_exited(body: Node3D) -> void:
	assert(body is Ship)
	#
	recalculate_capture_progress()
